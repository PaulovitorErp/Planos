#include "protheus.ch"
#include "apwebsrv.ch" 
#include "tbiconn.ch" 
#include "topconn.ch"

/*/{Protheus.doc} RCPGW002
WebService para cadastro de Contratos (Pré-cadastro)
@author TOTVS
@since 02/11/2016
@version P12
@param Nao recebe parametros
@return nulo
/*/

/***********************/
User Function RCPGW002()
/***********************/

WSSTRUCT aDadosCli

	WSDATA aCli as Array of wsEstrCli

ENDWSSTRUCT
	
WSSTRUCT wsEstrCli //Estrutura de Cliente

	/******************/
	//Campos Principais
	/******************/
	WSDATA cNome		as String	//Razao Social
	WSDATA cTpPessoa	as String	//Tipo de Pessoa Fisica ou Juridica
	WSDATA cNReduz		as String	//Nome Fantasia
	WSDATA cEnd			as String	//Endereço
	WSDATA cCompl		as String	//Complemento
	WSDATA cPtoRef		as String	//Ponto de Referencia
	WSDATA cBairro		as String	//Bairro
	WSDATA cEst			as String	//Estado 
	WSDATA cCodMun		as String	//Codigo do Municipio
	WSDATA cCep			as String	//CEP
	WSDATA cDdd			as String	//DDD
	WSDATA cTel			as String	//Telefone
	WSDATA cCgc			as String	//CGC
	WSDATA cRg			as String	//RG
	WSDATA cInscEst		as String	//Inscrição Estadual
	WSDATA cInscMun		as String	//Inscrição Municipal
	WSDATA cEmail		as String	//Email
	
	/******************/
	//Campos Auxiliares
	/******************/
	/*WSDATA cEndCob   	as String	//Endereço Cobrança
	WSDATA cCompCob		as String	//Complamento Cobrança
	WSDATA cPtoCob		as String	//Ponto de Referencia Cobrança
	WSDATA cBaiCob   	as String	//Bairro Cobrança
	WSDATA cEstCob		as String	//Estado Cobranca
	WSDATA cMunCob		as String	//Municipio de Cobrança    
	WSDATA cCepCob		as String	//CEP Cobrança
	WSDATA cEstCiv		as String	//Estado Civil
	WSDATA dDtNasc		as String	//Data de Nascimento
	WSDATA cEstNasc		as String	//Estado de Nascimento
	WSDATA cMunNasc		as String	//Municipio de Cobrança    
	WSDATA cProfi		as String	//Profissão
	WSDATA cConj		as String	//Conjuge
	WSDATA cDddCob		as String	//DDD Cobrança
	WSDATA cCelCob		as String	//Celular Cobrança
	WSDATA cCel2Cob		as String	//Celular2 Cobrança
	WSDATA cContato		as String	//Contato
	WSDATA cTelCont		as String	//Telefone Contato
	WSDATA cHrCont		as String	//Hora Contato
	WSDATA cMsgCond		as String	//Recebe mensagem de condolências, S=Sim ou N=Não
	WSDATA cDddCom		as String	//DDD Comercial
	WSDATA cTelCom		as String	//Tel Comercial
	*/
ENDWSSTRUCT

WSSTRUCT aDadosContr

	WSDATA aContr as Array of wsEstrContr

ENDWSSTRUCT

WSSTRUCT wsEstrContr //Estrutura de Contrato

	/******************/
	//Campos Principais
	/******************/
	WSDATA cDtInc		as String	//Data de Inclusão do Contrato
	WSDATA cFAqui		as String	//Forma de Aquisição, I=Imediato ou P=Preventivo
	WSDATA cPlano		as String	//Plano
	WSDATA nValor		as Float	//Valor
	WSDATA nQtdParc		as Float	//Quantidade Parcelas
	WSDATA cDiaVenc		as String	//Dia Vencimento Parcelas ou data de vencimento da primeira parcela (AAAAMMDD)
	WSDATA cTpRea		as String	//Tipo Reajuste, sendo: V=Variável ou P=Parcela Fixa
	WSDATA cTpCob		as String	//Tipo Cobrança, sendo: B=Boleto Bancário Impresso ou E=Boleto Bancário E-mail ou C=Cobrança em Domicílio
								  	// ou O= Boleto Bancário Impresso + Boleto Bancário E-mail
ENDWSSTRUCT

WSSERVICE WS_CADCONTRCEM DESCRIPTION "Serviço para cadastro de Contratos - Cemitério"

	WSDATA aEstCli	    as aDadosCli
	WSDATA aEstContr   	as aDadosContr

	//Dados de resposta
	WSDATA cRet			as String

	WSMETHOD CadContrCem Description "Cadastra Contrato - Cemitério"

ENDWSSERVICE

WSMETHOD CadContrCem WSRECEIVE aEstCli,aEstContr WSSEND cRet WSSERVICE WS_CADCONTRCEM

Local cInf			:= ""
Local aRet			:= {}

Private cMsgErr		:= ""

Private cCliWs		:= ""
Private cLojaCliWs	:= ""
Private cNomeCliWs	:= ""
Private cCpfCliWs	:= ""

Private cCodContr	:= ""
Private cPlanContr	:= ""
Private cDescPlan	:= ""

If Select("SX2") == 0
	RpcSetType(3)
	Reset Environment
	RpcSetEnv("01","0101")
Endif

If !Empty(aEstCli:aCli[1]:cCgc)

	DbSelectArea("SA1")
	SA1->(DbSetOrder(3)) //A1_FILIAL+A1_CGC
	
	If !SA1->(DbSeek(xFilial("SA1")+aEstCli:aCli[1]:cCgc))

		//Persistência - Dados Cliente
		Do Case
			Case Empty(aEstCli:aCli[1]:cNome) 
				cMsgErr	+= "INFORMACAO |NOME/RAZAO SOCIAL| OBRIGATORIA PARA INCLUSAO DO CLIENTE, OPERACAO CANCELADA." + CHR(13)+CHR(10)
		
			Case Empty(aEstCli:aCli[1]:cTpPessoa) 
				cMsgErr	+= "INFORMACAO |TIPO PESSOA| OBRIGATORIA PARA INCLUSAO DO CLIENTE, OPERACAO CANCELADA." + CHR(13)+CHR(10) 
		
			Case Empty(aEstCli:aCli[1]:cNReduz) 
				cMsgErr	+= "INFORMACAO |NOME FANTASIA| OBRIGATORIA PARA INCLUSAO DO CLIENTE, OPERACAO CANCELADA." + CHR(13)+CHR(10) 
		
			Case Empty(aEstCli:aCli[1]:cEnd) 
				cMsgErr	+= "INFORMACAO |ENDERECO| OBRIGATORIA PARA INCLUSAO DO CLIENTE, OPERACAO CANCELADA." + CHR(13)+CHR(10) 
		
			Case Empty(aEstCli:aCli[1]:cBairro) 
				cMsgErr	+= "INFORMACAO |BAIRRO| OBRIGATORIA PARA INCLUSAO DO CLIENTE, OPERACAO CANCELADA." + CHR(13)+CHR(10) 
		
			Case Empty(aEstCli:aCli[1]:cEst) 
				cMsgErr	+= "INFORMACAO |ESTADO| OBRIGATORIA PARA INCLUSAO DO CLIENTE, OPERACAO CANCELADA." + CHR(13)+CHR(10) 
		
			Case Empty(aEstCli:aCli[1]:cCodMun) 
				cMsgErr	+= "INFORMACAO |MUNICIPIO| OBRIGATORIA PARA INCLUSAO DO CLIENTE, OPERACAO CANCELADA." + CHR(13)+CHR(10) 

			Case Empty(aEstCli:aCli[1]:cCep) 
				cMsgErr	+= "INFORMACAO |CEP| OBRIGATORIA PARA INCLUSAO DO CLIENTE, OPERACAO CANCELADA." + CHR(13)+CHR(10) 
		EndCase
		
		If Empty(cMsgErr)
		
			If aEstCli:aCli[1]:cTpPessoa <> "F" .And. aEstCli:aCli[1]:cTpPessoa <> "J" 
				cMsgErr	+= "INFORMACAO |TIPO PESSOA| INVALIDA PARA INCLUSAO DO CLIENTE, OPERACAO CANCELADA." + CHR(13)+CHR(10) 
			Endif
			
			DbSelectArea("SX5")
			SX5->(DbSetOrder(1)) //X5_FILIAL+X5_TABELA+X5_CHAVE
			
			If !SX5->(DbSeek(xFilial("SX5")+"12"+aEstCli:aCli[1]:cEst)) 
				cMsgErr	+= "INFORMACAO |ESTADO| INVALIDA PARA INCLUSAO DO CLIENTE, OPERACAO CANCELADA." + CHR(13)+CHR(10) 
			Endif
		
			DbSelectArea("CC2")
			CC2->(DbSetOrder(1)) //CC2_FILIAL+CC2_EST+CC2_CODMUN
			
			If !CC2->(DbSeek(xFilial("CC2")+aEstCli:aCli[1]:cEst+aEstCli:aCli[1]:cCodMun))
				cMsgErr	+= "INFORMACAO |MUNICIPIO| INVALIDA PARA INCLUSAO DO CLIENTE, OPERACAO CANCELADA." + CHR(13)+CHR(10) 
			Endif
			
			If !CGC(aEstCli:aCli[1]:cCgc,,.F.)
				cMsgErr	+= "INFORMACAO |CGC| INVALIDA PARA INCLUSAO DO CLIENTE, OPERACAO CANCELADA." + CHR(13)+CHR(10) 
			Endif
		Endif
		//Fim da Persistência - Dados Cliente
	
		If Empty(cMsgErr)
			
			CadCli(aEstCli:aCli[1]:cNome,aEstCli:aCli[1]:cTpPessoa,aEstCli:aCli[1]:cNReduz,aEstCli:aCli[1]:cEnd,aEstCli:aCli[1]:cCompl,;
					aEstCli:aCli[1]:cPtoRef,aEstCli:aCli[1]:cBairro,aEstCli:aCli[1]:cEst,aEstCli:aCli[1]:cCodMun,aEstCli:aCli[1]:cCep,;
					aEstCli:aCli[1]:cDdd,aEstCli:aCli[1]:cTel,aEstCli:aCli[1]:cCgc,aEstCli:aCli[1]:cRg,aEstCli:aCli[1]:cInscEst,;
					aEstCli:aCli[1]:cInscMun,aEstCli:aCli[1]:cEmail)

			If Empty(cMsgErr)
				cInf += U_UXmlTag("CLIENTE","CLIENTE CADASTRADO COM SUCESSO",.T.)
			Endif
		Endif
	Else
		cCliWs 		:= SA1->A1_COD
		cLojaCliWs	:= SA1->A1_LOJA
		cNomeCliWs	:= SA1->A1_NOME
		cCpfCliWs	:= SA1->A1_CGC
	Endif
Else
	cMsgErr	+= "INFORMACAO |CGC| OBRIGATORIA PARA INCLUSAO DO CLIENTE, OPERACAO CANCELADA." + CHR(13)+CHR(10) 
Endif

If Empty(cMsgErr)

	//Persistência - Dados Contrato
	Do Case
		Case Empty(aEstContr:aContr[1]:cDtInc) 
			cMsgErr	+= "INFORMACAO |DATA INCLUSAO| OBRIGATORIA PARA INCLUSAO DO CONTRATO, OPERACAO CANCELADA." + CHR(13)+CHR(10)

		Case Empty(aEstContr:aContr[1]:cFAqui) 
			cMsgErr	+= "INFORMACAO |FORMA DE AQUISICAO| OBRIGATORIA PARA INCLUSAO DO CONTRATO, OPERACAO CANCELADA." + CHR(13)+CHR(10)

		Case Empty(aEstContr:aContr[1]:cPlano) 
			cMsgErr	+= "INFORMACAO |PLANO| OBRIGATORIA PARA INCLUSAO DO CONTRATO, OPERACAO CANCELADA." + CHR(13)+CHR(10)

		Case Empty(aEstContr:aContr[1]:nValor) 
			cMsgErr	+= "INFORMACAO |VALOR| OBRIGATORIA PARA INCLUSAO DO CONTRATO, OPERACAO CANCELADA." + CHR(13)+CHR(10)

		Case Empty(aEstContr:aContr[1]:nQtdParc) 
			cMsgErr	+= "INFORMACAO |QTD. PARCELAS| OBRIGATORIA PARA INCLUSAO DO CONTRATO, OPERACAO CANCELADA." + CHR(13)+CHR(10)

		Case Empty(aEstContr:aContr[1]:cDiaVenc) 
			cMsgErr	+= "INFORMACAO |DIA VENCIMENTO| OBRIGATORIA PARA INCLUSAO DO CONTRATO, OPERACAO CANCELADA." + CHR(13)+CHR(10)

		Case Empty(aEstContr:aContr[1]:cTpRea) 
			cMsgErr	+= "INFORMACAO |TIPO DE REAJUSTE| OBRIGATORIA PARA INCLUSAO DO CONTRATO, OPERACAO CANCELADA." + CHR(13)+CHR(10)

		Case Empty(aEstContr:aContr[1]:cTpCob) 
			cMsgErr	+= "INFORMACAO |TIPO DE COBRANCA| OBRIGATORIA PARA INCLUSAO DO CONTRATO, OPERACAO CANCELADA." + CHR(13)+CHR(10)
	EndCase

	If aEstContr:aContr[1]:cFAqui <> "I" .And. aEstContr:aContr[1]:cFAqui <> "P"
		cMsgErr	+= "INFORMACAO |FORMA DE AQUISICAO| INVALIDA PARA INCLUSAO DO CONTRATO, OPERACAO CANCELADA." + CHR(13)+CHR(10)
	Endif 

	DbSelectArea("U05")
	U05->(DbSetOrder(1)) //U05_FILIAL+U05_CODIGO
	
	If !U05->(DbSeek(xFilial("U05")+aEstContr:aContr[1]:cPlano))
		cMsgErr	+= "INFORMACAO |PLANO| INVALIDA PARA INCLUSAO DO CONTRATO, OPERACAO CANCELADA." + CHR(13)+CHR(10)
	Else
		cDescPlan := U05->U05_DESCRI
	Endif 

	If Mod(Val(aEstContr:aContr[1]:cDiaVenc),5) <> 0
		cMsgErr	+= "INFORMACAO |DIA DE VENCIMENTO| INVALIDA PARA INCLUSAO DO CONTRATO, OPERACAO CANCELADA." + CHR(13)+CHR(10)
	Endif 

	If aEstContr:aContr[1]:cTpRea <> "V" .And. aEstContr:aContr[1]:cTpRea <> "P"
		cMsgErr	+= "INFORMACAO |TIPO DE REAJUSTE| INVALIDA PARA INCLUSAO DO CONTRATO, OPERACAO CANCELADA." + CHR(13)+CHR(10)
	Endif 

	If aEstContr:aContr[1]:cTpCob <> "B" .And. aEstContr:aContr[1]:cTpCob <> "E" .And. aEstContr:aContr[1]:cTpCob <> "C" .And.;
		 aEstContr:aContr[1]:cTpCob <> "O"
		cMsgErr	+= "INFORMACAO |TIPO DE COBRANCA| INVALIDA PARA INCLUSAO DO CONTRATO, OPERACAO CANCELADA." + CHR(13)+CHR(10)
	Endif 	
	//Fim da Persistência - Dados Contrato
	
	If Empty(cMsgErr)	

		If CadContr(cCliWs,cLojaCliWs,aEstContr:aContr[1]:cDtInc,aEstContr:aContr[1]:cFAqui,aEstContr:aContr[1]:cPlano,aEstContr:aContr[1]:nValor,;
					aEstContr:aContr[1]:nQtdParc,aEstContr:aContr[1]:cDiaVenc,aEstContr:aContr[1]:cTpRea,aEstContr:aContr[1]:cTpCob)
			cInf += U_UXmlTag("CONTRATO","CONTRATO CADASTRADO COM SUCESSO",.T.)
		Endif
	Endif
Endif

//Envio de e-mail
If Empty(cMsgErr)
	EnvMail(cCliWs,cLojaCliWs,cNomeCliWs,cCpfCliWs,cCodContr,cPlanContr,cDescPlan)
Endif

aRet := {!Empty(cMsgErr),cMsgErr,cInf}

::cRet := TrataRet(aRet)

Return .T.

/****************************************************************************************************************************************/
Static Function CadCli(cNome,cTpPessoa,cNReduz,cEnd,cCompl,cPtoRef,cBairro,cEst,cCodMun,cCep,cDdd,cTel,cCgc,cRg,cInscEst,cInscMun,cEmail)
/****************************************************************************************************************************************/

Local lRet		:= .T.
Local aCliente 	:= {}

Private lMsErroAuto := .F.

AAdd(aCliente,{"A1_NOME"		,Upper(cNome)	,NIL}) 
AAdd(aCliente,{"A1_PESSOA"    	,cTpPessoa		,NIL})
AAdd(aCliente,{"A1_NREDUZ"		,Upper(cNReduz)	,NIL}) 
AAdd(aCliente,{"A1_END"			,Upper(cEnd)	,NIL}) 
AAdd(aCliente,{"A1_COMPL"		,Upper(cCompl)	,NIL}) 
AAdd(aCliente,{"A1_XREFERE"		,Upper(cPtoRef)	,NIL}) 
AAdd(aCliente,{"A1_BAIRRO"		,Upper(cBairro)	,NIL})
AAdd(aCliente,{"A1_EST"			,Upper(cEst)	,NIL}) 
AAdd(aCliente,{"A1_COD_MUN"		,cCodMun 		,NIL}) 
AAdd(aCliente,{"A1_CEP"			,cCep 			,NIL}) 
AAdd(aCliente,{"A1_DDD"			,cDdd			,NIL}) 
AAdd(aCliente,{"A1_TEL"			,cTel			,NIL}) 
AAdd(aCliente,{"A1_CGC"	    	,cCgc			,NIL})  
AAdd(aCliente,{"A1_RG"	    	,cRg			,NIL})  
AAdd(aCliente,{"A1_INSCR"		,cInscEst		,NIL}) 
AAdd(aCliente,{"A1_INSCRM"		,cInscMun		,NIL}) 
AAdd(aCliente,{"A1_EMAIL"		,Upper(cEmail)	,NIL}) 
			 
MsExecAuto({|x,y| MATA030(x,y)},aCliente,3) //Inclusão 
				
If lMsErroAuto
	MostraErro(cStartPath,"SA1_"+cCgc+".ERRO")
	cMsgErr	+= MemoRead(cStartPath + "SA1_"+cCgc+".ERRO")
	DisarmTransaction()
	lRet := .F.
Else
	cCliWs 		:= SA1->A1_COD
	cLojaCliWs	:= SA1->A1_LOJA
	cNomeCliWs	:= SA1->A1_NOME
	cCpfCliWs	:= SA1->A1_CGC
Endif

Return lRet

/******************************************************************************************************/
Static Function CadContr(cCliWs,cLojaCliWs,cDtInc,cFAqui,cPlano,nValor,nQtdParc,cDiaVenc,cTpRea,cTpCob)
/******************************************************************************************************/

Local oModel
Local oModelMaster  
Local oStructMaster 
Local aStructMaster

Local oModelU02 
Local oStructU02
Local aStructU02

Local nI				:= 0
Local lRet				:= .T.
Local aErro				:= {}

Local aContrato			:= {}
Local aAutorizados		:= {}
Local aMensagens		:= {}

Local nOpcao			:= 3 //Inclusão

Local cStatus			:= "P" //Pré-cadastro
Local cVend				:= SuperGetMv("MV_XVENDWS",.F.,"000611") //WEBSERVICE - INTEGRACAO SITE
Local nTxManut			:= SuperGetMv("MV_XTXMUWS",.F.,200) //Taxa de Manutenção
Local cIndice			:= SuperGetMv("MV_XINDIWS",.F.,"001") //INCC
Local lUsaPrimVencto	:= SuperGetMv("MV_XPRIMVC",.F.,.F.) //controla dia de vencimento pelo vencimento da primeira parcela


// Aqui ocorre o instanciamento do modelo de dados (Model)
oModel := FWLoadModel( 'RCPGA001' ) // MVC do Cadastro de Contratos

// Temos que definir qual a operação deseja: 3-Inclusão / 4-Alteração / 5-Exclusão
oModel:SetOperation(nOpcao)

// Antes de atribuirmos os valores dos campos temos que ativar o modelo
oModel:Activate()

// objetos da enchoice
oModelMaster 	:= oModel:GetModel('U00MASTER') // Instanciamos apenas referentes aos dados
oStructMaster 	:= oModelMaster:GetStruct() // Obtemos a estrutura de dados da enchoice
aStructMaster	:= oStructMaster:GetFields() // Obtemos os campos     

// objetos do grid da tabela U02 - Autorizados
oModelU02		:= oModel:GetModel('U02DETAIL') // Intanciamos apenas a parte do modelo referente ao grid
oStructU02		:= oModelU02:GetStruct() // Obtemos a estrutura de dados do grid
aStructU02		:= oStructU02:GetFields() // Obtemos os campos 

AAdd( aContrato, {'U00_DATA'        , CToD(cDtInc) } )
AAdd( aContrato, {'U00_FAQUIS'      , cFAqui } ) 
AAdd( aContrato, {'U00_PLANO'       , cPlano } )
AAdd( aContrato, {'U00_VENDED'      , cVend } ) 
AAdd( aContrato, {'U00_STATUS'      , cStatus } )
AAdd( aContrato, {'U00_CLIENT'      , cCliWs } )
AAdd( aContrato, {'U00_LOJA'        , cLojaCliWs } )
AAdd( aContrato, {'U00_VALOR'    	, nValor } )
AAdd( aContrato, {'U00_QTDPAR'      , nQtdParc } ) 

//valido se controle o vencimento pelo campo dia de vencimento 
//ou data de vencimento da primeira parcela
if lUsaPrimVencto
	AAdd( aContrato, {'U00_PRIMVE'      , STOD(cDiaVenc) } )
else
	AAdd( aContrato, {'U00_DIAVEN'      , cDiaVenc } )
endif

AAdd( aContrato, {'U00_REAJUS'    	, cTpRea } )
AAdd( aContrato, {'U00_TPCOBR'    	, cTpCob } )
AAdd( aContrato, {'U00_TXMANU'      , nTxManut } ) 
AAdd( aContrato, {'U00_INDICE'      , cIndice } )

// percorro os campos do cabeçalho
For nI := 1 To Len(aContrato)
	// Verifica se os campos passados existem na estrutura do modelo
	If ( aScan(aStructMaster,{|x| AllTrim( x[3] )== AllTrim(aContrato[nI][1]) } ) ) > 0
		// Realiza a atribuição do dado ao campo do Model
		If !( oModel:SetValue( 'U00MASTER', aContrato[nI][1], (aContrato[nI][2] )) )
			lRet := .F.
			Exit
		EndIf
	EndIf
Next nI

// se os campos do cabeçalho foram setados com sucesso
If lRet  

	If lRet .And. Len(aAutorizados) > 0  
		lRet := AddGrids(@oModel,@oModelU02,aStructU02,aAutorizados,"U02DETAIL",'U02_ITEM') 
	EndIf
	
	If lRet .And. Len(aMensagens) > 0  
		lRet := AddGrids(@oModel,@oModelU03,aStructU03,aMensagens,"U03DETAIL",'U03_ITEM') 
	EndIf
	
	// Faz-se a validação dos dados
	If lRet .And. ( lRet := oModel:VldData() )
		// Se o dados foram validados faz-se a grava?o efetiva dos dados (commit)
		oModel:CommitData()
	EndIf
EndIf

If !lRet

	// Se os dados nao foram validados obtemos a descricao do erro para gerar LOG ou mensagem de aviso
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
Else
	cCodContr	:= U00->U00_CODIGO
EndIf

oModel:DeActivate()

Return(lRet)

/***********************************************************************************/
Static Function AddGrids(oModel,oModelGrid,aStructDetail,aArray,cModelDt,cUniqueCpo)
/***********************************************************************************/

Local nI         := 0 
Local nJ	     := 0 
Local nItErro    := 0 
Local nLinhaItem := 0 
Local nPosItem	 := 0 
Local lRetorno   := .T.

For nI := 1 To Len(aArray)  

	// Incluímos uma linha nova
	// ATENCAO: O itens são criados em uma estrura de grid (FORMGRID), portanto já é criada uma primeira linha
	//branco automaticamente, desta forma começamos a inserir novas linhas a partir da 2ª vez
	nPosItem   := aScan( aArray[nI], { |x| AllTrim( x[1] ) ==  AllTrim( cUniqueCpo ) } )
		
	//pesquiso se item ja existe na grid, caso sim, apenas atualizo a mesma.
	If nPosItem > 0 
		nLinhaItem := FindItem(oModelGrid,cUniqueCpo,aArray[nI][nPosItem][2])
	EndIf
		
	If nLinhaItem == 0 
			
		If nI > 1
			// Incluimos uma nova linha de item
			If  ( nItErro := oModelGrid:AddLine() ) = 0//nI
				// Se por algum motivo o metodo AddLine() não consegue incluir a linha,
				// ele retorna a quantidade de linhas já
				// existem no grid. Se conseguir retorna a quantidade mais 1
				lRetorno    := .F.
				Exit
			EndIf
		EndIf
	Else
	   	oModelGrid:GoLine( nLinhaItem )
	EndIf
	    
	For nJ := 1 To Len( aArray[nI] )
		// Verifica se os campos passados existem na estrutura de item
		If ( aScan( aStructDetail, { |x| AllTrim( x[3] ) ==  AllTrim( aArray[nI][nJ][1] ) } ) ) > 0
			If !( oModel:SetValue(cModelDt, aArray[nI][nJ][1], aArray[nI][nJ][2] ) )
				// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
				// o método SetValue retorna .F.
				lRetorno    := .F.
				nItErro     := nI
				Exit
			EndIf 
		EndIf  
	Next

	If !lRetorno
		Exit
	EndIf
Next nI

Return(lRetorno)

/************************************************/
Static Function FindItem(oModelGrid,cCampo,cItem)
/************************************************/

Local nRetLinha := 0 
Local nI        := 0 
             
For nI := 1 To oModelGrid:Length()
	
	oModelGrid:GoLine( nI )
	
	If Alltrim(oModelGrid:GetValue(cCampo)) == Alltrim(cItem)
   		nRetLinha  := nI  
   		Exit
	EndIf

Next nI

Return(nRetLinha)

/*****************************/
Static Function TrataRet(aRet)
/*****************************/

Local cCabXml	:= '<?xml version="1.0" encoding="ISO-8859-1"?>' + CHR(13)+CHR(10) 
Local cErro 	:= ""

cErro := U_UXmlTag("ERRO",;
			U_UXmlTag("STATUS",IIF(aRet[1],"TRUE","FALSE"))+;
			U_UXmlTag("MENSAGEM",aRet[2]);
		,.T.)

Return cCabXml + "<RETORNOPROTHEUS>" + chr(13)+chr(10) + cErro + aRet[3] + "</RETORNOPROTHEUS>"

/*********************************************************************************************/
Static Function EnvMail(cCliWs,cLojaCliWs,cNomeCliWs,cCpfCliWs,cCodContr,cPlanContr,cDescPlan)
/*********************************************************************************************/

Local cServer 		:= AllTrim(GetNewPar("MV_RELSERV","")) //Servidor de envio de E-mail: smtp.gmail.com:587
Local cFrom			:= AllTrim(SuperGetMv("MV_XCTAMLD",.F.,"protheus.md@valedocerrado.com.br")) //Conta Servidor de E-mail: protheus.md@valedocerrado.com.br
Local cAccount		:= Alltrim(SuperGetMv("MV_XUSRMLD",.F.,"protheus.md@valedocerrado.com.br")) //Usuário para autenticação no Servidor de E-mail: protheus.md@valedocerrado.com.br
Local cPassword		:= Alltrim(SuperGetMv("MV_XPASMLD",.F.,"totvs*1234")) //Senha para autenticação no Servidor de E-mail: totvs*1904/totvs*1234
Local lAutentica	:= GetMv("MV_RELAUTH") //Determina se o Servidor de Email necessita de Autenticação. Atualmente igual a .T.
Local cNomeCom		:= AllTrim(U_RetInfSM0(cEmpAnt,cFilAnt,"M0_NOMECOM")) // Nome COmercial da Empresa Logada
Local cSubject		:= "Comunicado - Integração via site " + cNomeCom
Local cBody			:= ""
Local aTo			:= StrTokArr(SuperGetMv("MV_XMAILST",.F.,""),"/")
Local nI
Local nStart		:= 0
Local lOk
Local lContinua		:= .T.
Local nCont			:= 0

Private cStartPath

cStartPath := GetPvProfString(GetEnvServer(),"StartPath","ERROR",GetAdv97())
cStartPath += If(Right(cStartPath, 1) <> "\", "\", "")  

if Empty(cServer)
	
	FwLogMsg("ERROR", , "REST", FunName(), "", "01", "Servidor de Envio de E-mail não definido no parâmetro <MV_RELSERV>.", 0, (nStart - Seconds()), {})

	lContinua := .F.
Endif

If lContinua
	
	If Empty(cFrom)
	
		FwLogMsg("ERROR", , "REST", FunName(), "", "01", "Conta para acesso ao Servidor de E-mail não definida no parâmetro <MV_RELACNT>.", 0, (nStart - Seconds()), {})

		lContinua := .F.
	Endif
Endif

If lContinua

	For nI := 1 To Len(aTo)

		cTo := aTo[nI]
	
		CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lOk
		
		If !lOk
			
			FwLogMsg("ERROR", , "REST", FunName(), "", "01", "Falha na conexão com Servidor de E-Mail.", 0, (nStart - Seconds()), {})

		Else
			If lAutentica .And. !MailAuth(cAccount,cPassword)
			
				FwLogMsg("ERROR", , "REST", FunName(), "", "01", "Falha na autenticação do usuário.", 0, (nStart - Seconds()), {})

				DISCONNECT SMTP SERVER
				Return
			Endif
			
			cBody := RetBody(cCliWs,cLojaCliWs,cNomeCliWs,cCpfCliWs,cCodContr,cPlanContr,cDescPlan)
			
			SEND MAIL FROM cFrom TO cTo SUBJECT cSubject BODY cBody RESULT lOK
			
			If !lOK

				FwLogMsg("ERROR", , "REST", FunName(), "", "01", "Falha no envio do destinatário: "+aTo[nI]+".", 0, (nStart - Seconds()), {})

			Endif
		Endif
				
		DISCONNECT SMTP SERVER
	Next
Endif   

Return

/*********************************************************************************************/
Static Function RetBody(cCliWs,cLojaCliWs,cNomeCliWs,cCpfCliWs,cCodContr,cPlanContr,cDescPlan)
/*********************************************************************************************/

Local cHtml 	:= ""

cHtml := '<html>'
cHtml += '	<head>'
cHtml += '		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">'
cHtml += '	</head>'
cHtml += '	<body>'
cHtml += '		<p align="left"><font face="Arial" size="2">Cliente: '+AllTrim(cCliWs)+' - '+AllTrim(cLojaCliWs)+' / '+cNomeCliWs+'</br>'
cHtml += '		'+AllTrim(cCpfCliWs)+'</br>'
cHtml += '		'+AllTrim(cCodContr)+'</br>'
cHtml += '		'+AllTrim(cPlanContr)+' - '+AllTrim(cDescPlan)+'</p>'
cHtml += '	</body>'
cHtml += '</html>'

Return cHtml