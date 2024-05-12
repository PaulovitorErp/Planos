#include 'protheus.ch'
#include 'parmtype.ch'
#include 'fwmvcdef.ch'

/*/{Protheus.doc} RCPGA046
Cadastro de regras de manutenção

@type function
@version 
@author g.sampaio
@since 11/08/2020
@return nil
/*/
User Function RCPGA046()
	Local oBrowse

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias("U79")
	oBrowse:SetDescription("Regras de Taxa de Manuntenção")
	oBrowse:Activate()

Return(Nil)

/*/{Protheus.doc} MenuDef
//Função que cria os menus
@author g.sampaio
@since 11/08/2020
@version undefined

@type function
/*/
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina Title 'Pesquisar'   					Action 'PesqBrw'          	OPERATION 01 ACCESS 0
	ADD OPTION aRotina Title 'Visualizar'  					Action 'VIEWDEF.RCPGA046' 	OPERATION 02 ACCESS 0
	ADD OPTION aRotina Title 'Incluir'     					Action 'VIEWDEF.RCPGA046' 	OPERATION 03 ACCESS 0
	ADD OPTION aRotina Title 'Alterar'     					Action 'VIEWDEF.RCPGA046' 	OPERATION 04 ACCESS 0
	ADD OPTION aRotina Title 'Excluir'     					Action 'VIEWDEF.RCPGA046' 	OPERATION 05 ACCESS 0
	ADD OPTION aRotina Title 'Imprimir'    					Action 'VIEWDEF.RCPGA046' 	OPERATION 08 ACCESS 0
	ADD OPTION aRotina Title 'Copiar'      					Action 'VIEWDEF.RCPGA046' 	OPERATION 09 ACCESS 0
//ADD OPTION aRotina Title 'Legenda'     					Action 'U_CPGA008LEG()' 	OPERATION 10 ACCESS 0

Return(aRotina)

/*/{Protheus.doc} ModelDef
//Função que cria o objeto model.
@author g.sampaio
@since 11/08/2020
@version undefined

@type function
/*/
Static Function ModelDef()

	Local oStruU79 := FWFormStruct( 1, 'U79', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oStruU80 := FWFormStruct( 1, 'U80', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oStruU81 := FWFormStruct( 1, 'U81', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oModel

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( 'PCPGA046', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	/////////////////////////  CABEÇALHO - CATEGORIAS  ////////////////////////////

	// Crio a Enchoice com os campos do cadastro de categorias de comissões
	oModel:AddFields( 'U79MASTER', /*cOwner*/, oStruU79 )

	// Adiciona a chave primaria da tabela principal
	oModel:SetPrimaryKey({ "U79_FILIAL" , "U79_CODIGO" })

	// Preencho a descrição da entidade
	oModel:GetModel('U79MASTER'):SetDescription('Dados da Regra:')

	///////////////////////////  ITENS - CONDIÇÕES  //////////////////////////////

	// Crio o grid de modulos
	oModel:AddGrid( 'U80DETAIL', 'U79MASTER', oStruU80, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

	// Faço o relaciomaneto entre o modulo e a categoria
	oModel:SetRelation( 'U80DETAIL', { { 'U80_FILIAL', 'xFilial("U80")' } , { 'U80_CODIGO', 'U79_CODIGO' } } , U80->(IndexKey(1)) )

	// Preencho a descrição da entidade
	oModel:GetModel('U80DETAIL'):SetDescription('Formas de Pagamento:')

	// Não permitir duplicar o código do condicao
	oModel:GetModel('U80DETAIL'):SetUniqueLine( {'U80_FORMA'} )

	///////////////////////////  ITENS - PARCELAMENTO  //////////////////////////////

	// Crio o grid de parcelamento
	oModel:AddGrid('U81DETAIL', 'U80DETAIL', oStruU81, /*bLinePre*/, /*bLinePost*/{ |oFieldModel| FieldValidPos(oFieldModel)}, /*bPreVal*/, /*bPosVal*/, /*BLoad*/)

	// Faço o relacionamento entre o condição e o parcelamento
	oModel:SetRelation('U81DETAIL', { { 'U81_FILIAL', 'xFilial("U81")' } , { 'U81_CODIGO', 'U79_CODIGO' } , { 'U81_ITEMFO', 'U80_ITEM' } } , U81->(IndexKey(1)))

	// Preencho a descrição da entidade
	oModel:GetModel('U81DETAIL'):SetDescription('Regras de Geração de Taxa:')

Return(oModel)

/*/{Protheus.doc} ViewDef
//Função que cria o objeto View.
@author g.sampaio
@since 11/08/2020
@version undefined

@type function
/*/
Static Function ViewDef()

	Local oStruU79 	:= FWFormStruct(2,'U79')
	Local oStruU80 	:= FWFormStruct(2,'U80')
	Local oStruU81 	:= FWFormStruct(2,'U81')
	Local oModel   	:= FWLoadModel('RCPGA046')
	Local oView

	// Cria o objeto de View
	oView := FWFormView():New()

	// removo os campos
	oStruU80:RemoveField('U80_CODIGO')
	oStruU81:RemoveField('U81_CODIGO')
	oStruU81:RemoveField('U81_ITEMFO')

	// Define qual o Modelo de dados será utilizado
	oView:SetModel(oModel)

	oView:AddField('VIEW_U79', oStruU79, 'U79MASTER') // cria o cabeçalho - Categoria
	oView:AddGrid( 'VIEW_U80', oStruU80, 'U80DETAIL') // cria o grid - Condição
	oView:AddGrid( 'VIEW_U81', oStruU81, 'U81DETAIL') // cria o grid - Parcelamento

	// Crio os Panel's horizontais
	oView:CreateHorizontalBox('PANEL_CABEC', 30)
	oView:CreateHorizontalBox('PANEL_MEIO' , 35)
	oView:CreateHorizontalBox('PANEL_RODAP', 35)

	// Relaciona o ID da View com os panel's
	oView:SetOwnerView('VIEW_U79' , 'PANEL_CABEC')
	oView:SetOwnerView('VIEW_U80' , 'PANEL_MEIO' )
	oView:SetOwnerView('VIEW_U81' , 'PANEL_RODAP')

	// Ligo a identificacao do componente
	oView:EnableTitleView('VIEW_U79')
	oView:EnableTitleView('VIEW_U80')
	oView:EnableTitleView('VIEW_U81')

	// Define fechamento da tela ao confirmar a operação
	oView:SetCloseOnOk({||.T.})

	// Define campos que terao Auto Incremento
	oView:AddIncrementField( 'VIEW_U80', 'U80_ITEM' )
	oView:AddIncrementField( 'VIEW_U81', 'U81_ITEM' )

Return(oView)

/*/{Protheus.doc} UCPG46FP
Funcao para validacao do campo de forma de pagamento (U80_FORMA)
para preencher o campo descricao

@type function
@version 
@author g.sampaio
@since 12/08/2020
@return logical, retorno logico da validacao do campo
/*/
User Function UCPG46FP()

	Local cDescFPag         := ""
	Local lRetorno  		:= .T.
	Local nLinhaAtual       := 0
	Local oModel			:= FWModelActive()
	Local oView				:= FWViewActive()
	Local oModelU80			:= oModel:GetModel("U80DETAIL")

	// pega a linha atual do Modelo de dados
	nLinhaAtual     := oModelU80:GetLine()

	if nLinhaAtual > 0

		// pego a linha atual
		oModelU80:GoLine(nLinhaAtual)

		// descricao da forma de pgamento
		cDescFPag := Posicione("SX5", 1, XFILIAL("SX5") + "24" +  oModelU80:GetValue( "U80_FORMA" ), "X5_DESCRI" )

		// preencho o campo de descricao
		oModelU80:LoadValue( 'U80_DESCRI', cDescFPag )

	endIf

Return(lRetorno)

/*/{Protheus.doc} UCPG46CG
Funcao para validacao do when de acordo
com o preenchimento do campo U79_CGERA

@type function
@version 
@author g.sampaio
@since 12/08/2020
@return logical, retorno logico da validacao do campo
/*/
User Function UCPG46CG()

	Local cFieldAlt		    := SubStr( AllTrim( ReadVar() ), 4 )
	Local cComoGera         := ""
	Local lRetorno  		:= .F.
	Local oModel			:= FWModelActive()
	Local oView				:= FWViewActive()
	Local oModelU79			:= oModel:GetModel("U79MASTER")

	// pego o conteudo do campo como gera
	cComoGera := oModelU79:GetValue( "U79_CGERA" )

	// valido as regras de utilizacao
	if cFieldAlt == "U81_ATVINI" .And. cComoGera == "2" // campo ativcao inicial e aniversario do contrato
		lRetorno := .T.

	elseIf cFieldAlt == "U81_ATVFIM" .And. cComoGera == "2" // campo ativcao final e aniversario do contrato
		lRetorno := .T.

	elseIf cFieldAlt == "U81_GERACA" .And. cComoGera == "2" // campo geracao e aniversario do contrato
		lRetorno := .T.

	elseIf cFieldAlt == "U81_QUANDO" .And. cComoGera $ "1/3" // campo quando e apos o endereçamento
		lRetorno := .T.
	endIf

Return(lRetorno)

/*/{Protheus.doc} FieldValidPos
validacao pos alteracao do modelo de dados de Regras das Taxas

@type function
@version 
@author g.sampaio
@since 13/08/2020
@param oFieldModel, object, param_description
@return logical, retorno lógico do modelo de dados
/*/
Static Function FieldValidPos(oFieldModel)

	Local lRetorno          := .T.
	Local nLinhaAtual       := 0
	Local nItem             := 0
	Local nAtvIniAux        := 0
	Local nAtvFimAux        := 0
	Local oModel			:= FWModelActive()
	Local oView				:= FWViewActive()
	Local oModelU79         := oModel:GetModel("U79MASTER")

	//========================================================
	// Validacoes gerais
	//========================================================

	// para validar o conteudo do campo de vencimento
	if lRetorno .And. oFieldModel:GetValue("U81_VENCIM") > 31

		// retorno falso da validacao
		lRetorno := .F.

		// mensagem para o usuario
		oFieldModel:GetModel():SetErrorMessage('U81DETAIL', "U81_VENCIM" , 'U81DETAIL' , 'U81_VENCIM' , "Problema no Campo <b>Vencimento</b>",;
			'Não é possível atribuir valor ao campo Vencimento com valor maior que "31" (trinta e um)',;
			'Preencha o campo venciento com um dia válido de um mês normal, ou deixe o campo zerado.' )

	elseIf lRetorno .And. oFieldModel:GetValue("U81_QTDPAR") == 0 // valido se a quantidade de parcela foi preenchida

		// retorno falso da validacao
		lRetorno := .F.

		// mensagem para o usuario
		oFieldModel:GetModel():SetErrorMessage('U81DETAIL', "U81_QTDPAR" , 'U81DETAIL' , 'U81_QTDPAR' , "Problema no Campo <b>Qtd Parcelas</b>",;
			'Preencha a quantidade de parcelas para a geração de taxa de manutenção.',;
			'O conteúdo do campo quantidade de parcelas deve ser maior que zero.' )

	elseIf lRetorno .And. oFieldModel:GetValue("U81_INTERV") == 0 // valido se o intervalo entre as parcelas foi preenchido

		// retorno falso da validacao
		lRetorno := .F.

		// mensagem para o usuario
		oFieldModel:GetModel():SetErrorMessage('U81DETAIL', "U81_INTERV" , 'U81DETAIL' , 'U81_INTERV' , "Problema no Campo </b>Intervalo</b>",;
			'Preencha o intervalo de meses entre cada parcela para a geração de taxa de manutenção.',;
			'O conteúdo do Intervalo deve ser maior que zero.' )

	endIf

	//===========================================================
	// Validacoes especificas para cada tipo do campo U79_CGERA
	//===========================================================

	// validacao de campos preenchidos
	if lRetorno .And. oModelU79:GetValue("U79_CGERA") $ "1/3" // validacoes para ativacao e apos o enderecamento

		If lRetorno .And. oFieldModel:GetValue("U81_QUANDO") == 0 // valido se a quantidade de parcela foi preenchida

			// vou exibir o alerta mas nao interrompo a continuidade do processo
			MsgAlert("Quando a geração da Taxa de Manutenção for 'Ativação' ou 'Após o Endereçamento' o campo quando for zerado o sistema irá gerar";
				+ " a parcela no mês seguinte a geração da taxa de manutenção!","Alerta campo 'Quando?")

		endIf

	elseIf lRetorno .And. oModelU79:GetValue("U79_CGERA") == "2" // validacoes para quando for aniversario do contrato

		If lRetorno .And. Empty(oFieldModel:GetValue("U81_ATVINI")) // valido se a quantidade de parcela foi preenchida

			// retorno falso da validacao
			lRetorno := .F.

			// mensagem para o usuario
			oFieldModel:GetModel():SetErrorMessage('U81DETAIL', "U81_ATVINI" , 'U81DETAIL' , 'U81_ATVINI' , "Problema no Campo <b>Ativ.Inicial</b>",;
				'O campo Ativação Inicial deve estar preenchido com o primeiro mês da faixa de meses em que o contrato foi ativado para a geração da taxa de manutenção.',;
				'' )

		elseif lRetorno .And. Empty(oFieldModel:GetValue("U81_ATVFIM"))

			// retorno falso da validacao
			lRetorno := .F.

			// mensagem para o usuario
			oFieldModel:GetModel():SetErrorMessage('U81DETAIL', "U81_ATVFIM" , 'U81DETAIL' , 'U81_ATVFIM' , "Problema no Campo <b>Ativ.Final</b>",;
				'O campo Ativação Final deve estar preenchido com o último mês da faixa de meses em que o contrato foi ativado para a geração da taxa de manutenção.',;
				'' )

		elseif lRetorno .And. Empty(oFieldModel:GetValue("U81_GERACA"))

			// retorno falso da validacao
			lRetorno := .F.

			// mensagem para o usuario
			oFieldModel:GetModel():SetErrorMessage('U81DETAIL', "U81_GERACA" , 'U81DETAIL' , 'U81_GERACA' , "Problema no Campo <b>Geração</b>",;
				'Preencha o mês de Geração para o intervalo de ativação do contrato para a geração de taxa de manutenção.',;
				'O conteúdo do Intervalo deve ser maior que zero.' )


		endIf

	endIf

	// validacao para quando utilizar o campo ativacao inicial e final
	if lRetorno .And. oModelU79:GetValue("U79_CGERA") == "2" // para quando o como gera for aniversario do contrato

		// parcela inicial
		nAtvIniAux := Val(oFieldModel:GetValue("U81_ATVINI"))

		// parcela final
		nAtvFimAux := Val(oFieldModel:GetValue("U81_ATVFIM"))

		// pego a linha atual
		nLinhaAtual := oFieldModel:GetLine()

		// percorro os itens do modelo de dados
		for nItem := 1 to oFieldModel:Length()

			// posiciono na linha
			oFieldModel:GoLine(nItem)

			// verifico se estou na linha diferente da atual
			if nLinhaAtual <> oFieldModel:GetLine()

				// valido se a parcela inicial esta entre a parcela inicial e final de outra linha
				if nAtvIniAux >= Val(oFieldModel:GetValue("U81_ATVINI")) .And. nAtvIniAux <= Val(oFieldModel:GetValue("U81_ATVFIM"))

					// retorno negativo da validacao
					lRetorno := .F.

					// mensagem para o usuario
					oFieldModel:GetModel():SetErrorMessage('U81DETAIL', "U81_ATVINI" , 'U81DETAIL' , 'U81_ATVINI' , 'Problema no Campo <b>Ativ.Inicial</b>',;
						'O campo <b>Ativ.Inicial</b> deve ser preenchido com um intervalo diferente do já utilizado no item: ' + oFieldModel:GetValue("U81_ITEM") )

					// valido se a parcela final esta entre a parcela inicial e final de outra linha
				elseif nAtvFimAux >= Val(oFieldModel:GetValue("U81_ATVINI"))  .And. nAtvFimAux <= Val(oFieldModel:GetValue("U81_ATVFIM"))

					// retorno negativo da validacao
					lRetorno := .F.

					// mensagem para o usuario
					oFieldModel:GetModel():SetErrorMessage('U81DETAIL', "U81_ATVFIM" , 'U81DETAIL' , 'U81_ATVFIM' , 'Problema no Campo <b>Ativ.Final</b>',;
						'O campo <b>Ativ.Final</b> deve ser preenchido com um intervalo diferente do já utilizado no item: ' + oFieldModel:GetValue("U81_ITEM") )

				endIf

			endIf

		next nItem

	endIf

Return(lRetorno)

/*/{Protheus.doc} UCPG46CALCICLO
Funcao para validacao do campo de qtd.Parcelas (U81_QTDPAR) e Intervalo (U81_INTERV)
para preencher o campo de ciclo

@type function
@version 
@author g.sampaio
@since 12/08/2020
@return logical, retorno logico da validacao do campo
/*/
User Function UCPG46CALCICLO()

	Local lRetorno  		:= .T.
	Local nLinhaAtual       := 0
	Local nCicloTaxa        := 0
	Local oModel			:= FWModelActive()
	Local oView				:= FWViewActive()
	Local oModelU81			:= oModel:GetModel("U81DETAIL")

	// pega a linha atual do Modelo de dados
	nLinhaAtual     := oModelU81:GetLine()

	if nLinhaAtual > 0

		// pego a linha atual
		oModelU81:GoLine(nLinhaAtual)

		// calculo a sugestao do ciclo
		nCicloTaxa := oModelU81:GetValue( "U81_QTDPAR" ) * oModelU81:GetValue( "U81_INTERV" )

		// preencho o campo de descricao
		oModelU81:LoadValue( 'U81_CICLO', nCicloTaxa )

	endIf

Return(lRetorno)

/*/{Protheus.doc} UCPG46VALCICLO
Funcao para validacao do campo de ciclo (U81_CICLO)

@type function
@version 
@author g.sampaio
@since 12/08/2020
@return logical, retorno logico da validacao do campo
/*/
User Function UCPG46VALCICLO()

	Local lRetorno  		:= .T.
	Local nLinhaAtual       := 0
	Local nCicloTaxa        := 0
	Local oModel			:= FWModelActive()
	Local oView				:= FWViewActive()
	Local oModelU81			:= oModel:GetModel("U81DETAIL")

	// pega a linha atual do Modelo de dados
	nLinhaAtual     := oModelU81:GetLine()

	if nLinhaAtual > 0

		// pego a linha atual
		oModelU81:GoLine(nLinhaAtual)

		// calculo a sugestao do ciclo
		nCicloTaxa := oModelU81:GetValue( "U81_QTDPAR" ) * oModelU81:GetValue( "U81_INTERV" )

		// verifico se o ciclo é diferente da Quantidade de parcelas multiplicado pelo intervalo
		if oModelU81:GetValue( "U81_CICLO" ) < nCicloTaxa

			// mensagem para o usuario
			oModelU81:GetModel():SetErrorMessage('U81DETAIL', "U81_CICLO" , 'U81DETAIL' , 'U81_CICLO' , "Problema no Campo Ciclo",;
				'Não é possível que o ciclo seja menor que a quantidade de parcelas multiplicado pelo intervalo entre parcelas.',;
				'O ciclo não pode ser menor que ' + cValToChar(nCicloTaxa) )

		endIf

	endIf

Return(lRetorno)

/*/{Protheus.doc} PICT46DESC
Funcao para definir a picture do campo
@author g.sampaio
@since 03/09/2020
@version undefined
@param nil
@type function
@return cPicture, caracter, retorna a picture do campo
/*/

User Function PICT46DESC()

	Local cPicture := ""

	If FwFldGet("U80_TPDESC") == "1" //1=Percentual
		cPicture := "@E 999.99"

	ElseIf FwFldGet("U80_TPDESC") == "2" //2=Valor em Reais
		cPicture := "@E 999,999.99"

	Else
		cPicture := "@E 999,999.99"

	EndIf

Return(cPicture)
