#include 'protheus.ch'
#include 'parmtype.ch'
#include 'fwmvcdef.ch'

/*/{Protheus.doc} RCPGA008
//Cadastro de Categoria de Comissão
Visa identificar o tipo de comissão que o vendedor possui e as características 
e parametros para cálculos de comissões e parcelamento de pagamento.

@author Pablo Cavalcante
@since 03/03/2016
@version undefined

@type function
/*/

User Function RCPGA008()
Local oBrowse

oBrowse := FWmBrowse():New()
oBrowse:SetAlias("U15")
oBrowse:SetDescription("Categoria de Comissão")   
oBrowse:Activate()

Return(Nil)

/*/{Protheus.doc} MenuDef
//Função que cria os menus
@author Pablo Cavalcante
@since 03/03/2016
@version undefined

@type function
/*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina Title 'Pesquisar'   					Action 'PesqBrw'          	OPERATION 01 ACCESS 0
ADD OPTION aRotina Title 'Visualizar'  					Action 'VIEWDEF.RCPGA008' 	OPERATION 02 ACCESS 0
ADD OPTION aRotina Title 'Incluir'     					Action 'VIEWDEF.RCPGA008' 	OPERATION 03 ACCESS 0
ADD OPTION aRotina Title 'Alterar'     					Action 'VIEWDEF.RCPGA008' 	OPERATION 04 ACCESS 0
ADD OPTION aRotina Title 'Excluir'     					Action 'VIEWDEF.RCPGA008' 	OPERATION 05 ACCESS 0
ADD OPTION aRotina Title 'Imprimir'    					Action 'VIEWDEF.RCPGA008' 	OPERATION 08 ACCESS 0
ADD OPTION aRotina Title 'Copiar'      					Action 'VIEWDEF.RCPGA008' 	OPERATION 09 ACCESS 0
//ADD OPTION aRotina Title 'Legenda'     					Action 'U_CPGA008LEG()' 	OPERATION 10 ACCESS 0

Return(aRotina)

/*/{Protheus.doc} ModelDef
//Função que cria o objeto model.
@author Pablo Cavalcante
@since 03/03/2016
@version undefined

@type function
/*/
Static Function ModelDef()

Local oStruU15 := FWFormStruct( 1, 'U15', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruU16 := FWFormStruct( 1, 'U16', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruU17 := FWFormStruct( 1, 'U17', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'PCPGA008', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

/////////////////////////  CABEÇALHO - CATEGORIAS  ////////////////////////////

// Crio a Enchoice com os campos do cadastro de categorias de comissões
oModel:AddFields( 'U15MASTER', /*cOwner*/, oStruU15 )

// Adiciona a chave primaria da tabela principal
oModel:SetPrimaryKey({ "U15_FILIAL" , "U15_CODIGO" })

// Preencho a descrição da entidade
oModel:GetModel('U15MASTER'):SetDescription('Categoria de Comissão:')

///////////////////////////  ITENS - CONDIÇÕES  //////////////////////////////

// Crio o grid de modulos
oModel:AddGrid( 'U16DETAIL', 'U15MASTER', oStruU16, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

// Faço o relaciomaneto entre o modulo e a categoria
oModel:SetRelation( 'U16DETAIL', { { 'U16_FILIAL', 'xFilial("U16")' } , { 'U16_CATEGO', 'U15_CODIGO' } } , U16->(IndexKey(1)) )

// Seto a propriedade de não obrigatoriedade do preenchimento do grid
//oModel:GetModel('U16DETAIL'):SetOptional( .T. )

// Preencho a descrição da entidade
oModel:GetModel('U16DETAIL'):SetDescription('Condições:')

// Não permitir duplicar o código do condicao
oModel:GetModel('U16DETAIL'):SetUniqueLine( {'U16_CODIGO'} )

///////////////////////////  ITENS - PARCELAMENTO  //////////////////////////////

// Crio o grid de parcelamento
oModel:AddGrid('U17DETAIL', 'U16DETAIL', oStruU17, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/)    

// Faço o relacionamento entre o condição e o parcelamento
oModel:SetRelation('U17DETAIL', { { 'U17_FILIAL', 'xFilial("U17")' } , { 'U17_CATEGO', 'U16_CATEGO' } , { 'U17_CONDIC', 'U16_CODIGO' } } , U17->(IndexKey(1)))

// Seto a propriedade de não obrigatoriedade do preenchimento do grid
//oModel:GetModel('U17DETAIL'):SetOptional(.F.)

// Preencho a descrição da entidade
oModel:GetModel('U17DETAIL'):SetDescription('Parcelamentos:')

// Não permitir duplicar o código do parcelamento
oModel:GetModel('U17DETAIL'):SetUniqueLine( {'U17_CODIGO'} )

Return(oModel)

/*/{Protheus.doc} ViewDef
//Função que cria o objeto View.
@author Pablo Cavalcante
@since 03/03/2016
@version undefined

@type function
/*/
Static Function ViewDef()

Local oStruU15 	:= FWFormStruct(2,'U15')
Local oStruU16 	:= FWFormStruct(2,'U16') 
Local oStruU17 	:= FWFormStruct(2,'U17')
Local oModel   	:= FWLoadModel('RCPGA008')
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel(oModel)

oView:AddField('VIEW_U15', oStruU15, 'U15MASTER') // cria o cabeçalho - Categoria
oView:AddGrid( 'VIEW_U16', oStruU16, 'U16DETAIL') // cria o grid - Condição
oView:AddGrid( 'VIEW_U17', oStruU17, 'U17DETAIL') // cria o grid - Parcelamento

// Crio os Panel's horizontais 
oView:CreateHorizontalBox('PANEL_CABEC', 38)
oView:CreateHorizontalBox('PANEL_MEIO' , 02)
oView:CreateHorizontalBox('PANEL_RODAP', 60)

oView:CreateVerticalBox('PANEL_LEFT' , 50, 'PANEL_RODAP')
oView:CreateVerticalBox('PANEL_RIGHT', 50, 'PANEL_RODAP')

// Relaciona o ID da View com os panel's
oView:SetOwnerView('VIEW_U15' , 'PANEL_CABEC')
oView:SetOwnerView('VIEW_U16' , 'PANEL_LEFT' )
oView:SetOwnerView('VIEW_U17' , 'PANEL_RIGHT')

// Ligo a identificacao do componente
oView:EnableTitleView('VIEW_U15')
oView:EnableTitleView('VIEW_U16')
oView:EnableTitleView('VIEW_U17')

// Define fechamento da tela ao confirmar a operação
oView:SetCloseOnOk({||.T.})

// Define campos que terao Auto Incremento
oView:AddIncrementField( 'VIEW_U16', 'U16_CODIGO' )
oView:AddIncrementField( 'VIEW_U17', 'U17_CODIGO' )

Return(oView)

/*/{Protheus.doc} CPGA008LEG
//Legenda do browser de cadastro de categoria de comissão.
@author Pablo Cavalcante
@since 03/03/2016
@version undefined

@type function
/*/
User Function CPGA008LEG()

	BrwLegenda("Status da Categoria de Comissão","Legenda",{ {"BR_VERDE","Ativa"},{"BR_VERMELHO","Inativa"} })

Return


/*/{Protheus.doc} RCPGB008
//Preencher com zeros a esquerda os campos U16_NPARDE, U16_NPARAT e U17_PRAZO.
@author Pablo Cavalcante
@since 08/03/2016
@version undefined

@type function
/*/
User Function RCPGB008()
Local oModel      		:= FWModelActive()
Local oModelU16   		:= oModel:GetModel('U16DETAIL')
Local oModelU17   		:= oModel:GetModel('U17DETAIL')
Local lUsaNovaComissao	:= SuperGetMv("ES_NEWCOMI",,.F.)	// ativo o uso da nova comissao

If !lUsaNovaComissao
	oModelU16:LoadValue('U16_NPARDE',PADL(AllTrim(oModelU16:GetValue('U16_NPARDE')),tamsx3('U16_NPARDE')[1],'0'))
	oModelU16:LoadValue('U16_NPARAT',PADL(AllTrim(oModelU16:GetValue('U16_NPARAT')),tamsx3('U16_NPARAT')[1],'0'))
	oModelU17:LoadValue('U17_PRAZO' ,PADL(AllTrim(oModelU17:GetValue('U17_PRAZO' )),tamsx3('U17_PRAZO ')[1],'0'))
EndIf

Return(.T.)


/*/{Protheus.doc} RCPGC008
//Validação de Campo U17_PERC, para preencher o campo U17_VALOR.
@author Pablo Cavalcante
@since 08/03/2016
@version undefined

@type function
/*/
User Function RCPGC008()
Local oModel      		:= FWModelActive()
Local oModelU15   		:= oModel:GetModel('U15MASTER')
Local oModelU16   		:= oModel:GetModel('U16DETAIL')
Local oModelU17   		:= oModel:GetModel('U17DETAIL')
Local lUsaNovaComissao	:= SuperGetMv("ES_NEWCOMI",,.F.)	// ativo o uso da nova comissao

If !lUsaNovaComissao
	If oModelU15:GetValue('U15_TPVAL') == 'V'
		oModelU17:LoadValue('U17_VALOR',(oModelU17:GetValue('U17_PERC')/100)*oModelU15:GetValue('U15_VAL'))
	ElseIf oModelU15:GetValue('U15_TPVAL') == 'P'
		oModelU17:LoadValue('U17_VALOR',(oModelU17:GetValue('U17_PERC')/100)*oModelU15:GetValue('U15_PERC'))
	EndIf
EndIf

Return(.T.)


/*/{Protheus.doc} RCPGD008
//Validação de Campo U17_VALOR, para preencher o campo U17_PERC.
@author Pablo Cavalcante
@since 08/03/2016
@version undefined

@type function
/*/
User Function RCPGD008()
Local oModel      		:= FWModelActive()
Local oModelU15   		:= oModel:GetModel('U15MASTER')
Local oModelU16   		:= oModel:GetModel('U16DETAIL')
Local oModelU17   		:= oModel:GetModel('U17DETAIL')
Local lUsaNovaComissao	:= SuperGetMv("ES_NEWCOMI",,.F.)	// ativo o uso da nova comissao

If !lUsaNovaComissao

	If oModelU15:GetValue('U15_TPVAL') == 'V'
		oModelU17:LoadValue('U17_PERC',(oModelU17:GetValue('U17_VALOR')/oModelU15:GetValue('U15_VAL'))*100)
	ElseIf oModelU15:GetValue('U15_TPVAL') == 'P'
		oModelU17:LoadValue('U17_PERC',(oModelU17:GetValue('U17_VALOR')/oModelU15:GetValue('U15_PERC'))*100)
	EndIf

EndIf

Return(.T.)

/*/{Protheus.doc} RCPGD008
//Validação de Campo U15_VAL para limpar a GRID de Parcelamentos
@author Raphael Martins
@since 09/08/2016
@version undefined

@type function
/*/

User Function RCPGE008() 

Local oModel      		:= FWModelActive()
Local oModelU17   		:= oModel:GetModel('U17DETAIL')
Local oView	      		:= FWViewActive()
Local lUsaNovaComissao	:= SuperGetMv("ES_NEWCOMI",,.F.)	// ativo o uso da nova comissao

If !lUsaNovaComissao

	U_LimpaAcolsMVC(oModelU17,oView)
	
	oView:Refresh()

EndIf

Return(.T.)

/*/{Protheus.doc} PICTCPG8
Funcao para definir a picture do campo
@author g.sampaio
@since 11/06/2019
@version undefined
@param nil
@type function
@return cPicture, caracter, retorna a picture do campo
/*/

User Function PICTCPG8()

Local cPicture := ""

If FwFldGet("U15_TPCOMI") == "1" //1=Parcelas Recebidas - Para cobradores

	cPicture := "@E 9999"

ElseIf FwFldGet("U15_TPCOMI") == "2" //2=Quantidade Vendida - Para atender a quantidade de Planos Vendidos. (Adm Planos
	
	cPicture := "@E 9999"

ElseIf FwFldGet("U15_TPCOMI") == "3" //3=Valor Vendido -Para atender o valor total vendido pelo vendedor. (CPG)
	
	cPicture := "@E 999,999,999.99"

ElseIf FwFldGet("U15_TPCOMI") == "4" //4=Por Parcelamento - Para atender os representantes

	cPicture := "@E 9999"

Else
	
	cPicture := "@E 999,999,999.99"

EndIf

Return(cPicture)

/*/{Protheus.doc} VALCPG8
Funcao para validação de campos
@author g.sampaio
@since 11/06/2019
@version undefined
@type function
@param 
@return lRetorno, caracter, retorna a picture do campo
/*/

User Function VALCPG8()

Local aArea         	:= GetArea()
Local aSaveLines		:= FWSaveRows()
Local lRetorno			:= .T.
Local nFaixaInicio      := 0
Local nFaixaFinal      	:= 0
Local oModel			:= Nil

oModel 			:= FWModelActive()
nFaixaInicio 	:= oModel:GetValue("U16DETAIL","U16_FXINIC") // pega o conteudo do campo U16_FXINIC
nFaixaFinal 	:= oModel:GetValue("U16DETAIL","U16_FXFIM") // pega o conteudo do campo U16_FXFIM

// vou validar o conteudo dos campos UI6_FXINIC e U16_FXFIM
If nFaixaInicio > 0 .and. nFaixaFinal > 0 .and. nFaixaInicio >= nFaixaFinal
        
    // retorna falso
    lRetorno := .F. 
        
    // help para o usuario
    Help(,,'Help',,'O conteúdo do campo <b>Fx Inicia (UI6_FXINIC)</b> não pode ser maior ou igual ao conteúdo do campo <b>Fx Final (U16_FXFIM)</b>!',1,0)

EndIf
    
//restauro as linhas posicionadas
FWRestRows( aSaveLines )

RestArea( aArea )

Return(lRetorno)

/*/{Protheus.doc} OPCCPG8
Funcao para validação do campo U15_TPVAL
@author g.sampaio
@since 01/08/2019
@version undefined
@type function
@param 
@return lRetorno, caracter, retorna a picture do campo
/*/

User Function OPCCPG8()

Local aArea         	:= GetArea()
Local aSaveLines		:= FWSaveRows()
Local lRetorno			:= .T.
Local nX				:= 0
Local oModel			:= Nil
Local oModelU17			:= Nil

// pego o modelo ativo
oModel 		:= FWModelActive()
oModelU17	:= oModel:GetModel('U17DETAIL')

// zerar o campo valor
If FwFldGet("U15_TPVAL")=="P"

	// percorro todos os itens da U17
	For nX := 1 To oModelU17:Length()

		// posiciono na linha atual
		oModelU17:Goline(nX)  

		// preencho o campo de tabela 
		oModelU17:SetValue('U17_VALOR' , 0)

	Next nX

ElseIf FwFldGet("U15_TPVAL")=="v" // zerar o campo percentual

	// percorro todos os itens da U17
	For nX := 1 To oModelU17:Length()

		// posiciono na linha atual
		oModelU17:Goline(nX)  

		// preencho o campo de tabela 
		oModelU17:SetValue('U17_PERC' , 0)

	Next nX

EndIf

Return(lRetorno)