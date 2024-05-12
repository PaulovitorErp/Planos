#include 'protheus.ch'
#include 'parmtype.ch'
#include 'fwmvcdef.ch'

/*/{Protheus.doc} RCPGA047
Cadastro de regras de negociação

@type function
@version 
@author g.sampaio
@since 11/08/2020
@return nil
/*/
User Function RCPGA047()
    Local oBrowse

    oBrowse := FWmBrowse():New()
    oBrowse:SetAlias("U83")
    oBrowse:SetDescription("Regras de Negociação")
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
    ADD OPTION aRotina Title 'Visualizar'  					Action 'VIEWDEF.RCPGA047' 	OPERATION 02 ACCESS 0
    ADD OPTION aRotina Title 'Incluir'     					Action 'VIEWDEF.RCPGA047' 	OPERATION 03 ACCESS 0
    ADD OPTION aRotina Title 'Alterar'     					Action 'VIEWDEF.RCPGA047' 	OPERATION 04 ACCESS 0
    ADD OPTION aRotina Title 'Excluir'     					Action 'VIEWDEF.RCPGA047' 	OPERATION 05 ACCESS 0
    ADD OPTION aRotina Title 'Imprimir'    					Action 'VIEWDEF.RCPGA047' 	OPERATION 08 ACCESS 0
    ADD OPTION aRotina Title 'Copiar'      					Action 'VIEWDEF.RCPGA047' 	OPERATION 09 ACCESS 0
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

    Local oStruU83 := FWFormStruct( 1, 'U83', /*bAvalCampo*/, /*lViewUsado*/ )
    Local oStruU84 := FWFormStruct( 1, 'U84', /*bAvalCampo*/, /*lViewUsado*/ )
    Local oStruU85 := FWFormStruct( 1, 'U85', /*bAvalCampo*/, /*lViewUsado*/ )
    Local oModel

    // Cria o objeto do Modelo de Dados
    oModel := MPFormModel():New( 'PCPGA047', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

    /////////////////////////  CABEÇALHO - CATEGORIAS  ////////////////////////////

    // Crio a Enchoice com os campos do cadastro de categorias de comissões
    oModel:AddFields( 'U83MASTER', /*cOwner*/, oStruU83 )

    // Adiciona a chave primaria da tabela principal
    oModel:SetPrimaryKey({ "U83_FILIAL" , "U83_CODIGO" })

    // Preencho a descrição da entidade
    oModel:GetModel('U83MASTER'):SetDescription('Dados da Regra:')

    ///////////////////////////  ITENS - CONDIÇÕES  //////////////////////////////

    // Crio o grid de modulos
    oModel:AddGrid( 'U84DETAIL', 'U83MASTER', oStruU84, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

    // Faço o relaciomaneto entre o modulo e a categoria
    oModel:SetRelation( 'U84DETAIL', { { 'U84_FILIAL', 'xFilial("U84")' } , { 'U84_CODIGO', 'U83_CODIGO' } } , U84->(IndexKey(1)) )

    // Preencho a descrição da entidade
    oModel:GetModel('U84DETAIL'):SetDescription('Formas de Pagamento:')

    // Não permitir duplicar o código do condicao
    oModel:GetModel('U84DETAIL'):SetUniqueLine( {'U84_FORMA'} )

    ///////////////////////////  ITENS - PARCELAMENTO  //////////////////////////////

    // Crio o grid de parcelamento
    oModel:AddGrid('U85DETAIL', 'U84DETAIL', oStruU85, /*bLinePre*/, /*bLinePost*/{ |oFieldModel| FieldValidPos(oFieldModel)}, /*bPreVal*/, /*bPosVal*/, /*BLoad*/)

    // Faço o relacionamento entre o condição e o parcelamento
    oModel:SetRelation('U85DETAIL', { { 'U85_FILIAL', 'xFilial("U85")' } , { 'U85_CODIGO', 'U83_CODIGO' } , { 'U85_ITEMFO', 'U84_ITEM' } } , U85->(IndexKey(1)))

    // Preencho a descrição da entidade
    oModel:GetModel('U85DETAIL'):SetDescription('Regras de Negocição:')

Return(oModel)

/*/{Protheus.doc} ViewDef
//Função que cria o objeto View.
@author g.sampaio
@since 11/08/2020
@version undefined

@type function
/*/
Static Function ViewDef()

    Local oStruU83 	:= FWFormStruct(2,'U83')
    Local oStruU84 	:= FWFormStruct(2,'U84')
    Local oStruU85 	:= FWFormStruct(2,'U85')
    Local oModel   	:= FWLoadModel('RCPGA047')
    Local oView

    // Cria o objeto de View
    oView := FWFormView():New()

    // removo os campos
    oStruU84:RemoveField('U84_CODIGO')
    oStruU85:RemoveField('U85_CODIGO')
    oStruU85:RemoveField('U85_ITEMFO')

    // Define qual o Modelo de dados será utilizado
    oView:SetModel(oModel)

    oView:AddField('VIEW_U83', oStruU83, 'U83MASTER') // cria o cabeçalho - Categoria
    oView:AddGrid( 'VIEW_U84', oStruU84, 'U84DETAIL') // cria o grid - Condição
    oView:AddGrid( 'VIEW_U85', oStruU85, 'U85DETAIL') // cria o grid - Parcelamento

    // Crio os Panel's horizontais
    oView:CreateHorizontalBox('PANEL_CABEC', 30)
    oView:CreateHorizontalBox('PANEL_MEIO' , 35)
    oView:CreateHorizontalBox('PANEL_RODAP', 35)

    // Relaciona o ID da View com os panel's
    oView:SetOwnerView('VIEW_U83' , 'PANEL_CABEC')
    oView:SetOwnerView('VIEW_U84' , 'PANEL_MEIO' )
    oView:SetOwnerView('VIEW_U85' , 'PANEL_RODAP')

    // Ligo a identificacao do componente
    oView:EnableTitleView('VIEW_U83')
    oView:EnableTitleView('VIEW_U84')
    oView:EnableTitleView('VIEW_U85')

    // Define fechamento da tela ao confirmar a operação
    oView:SetCloseOnOk({||.T.})

    // Define campos que terao Auto Incremento
    oView:AddIncrementField( 'VIEW_U84', 'U84_ITEM' )
    oView:AddIncrementField( 'VIEW_U85', 'U85_ITEM' )

Return(oView)

/*/{Protheus.doc} UCPG47FP
Funcao para validacao do campo de forma de pagamento (U84_FORMA)
para preencher o campo descricao

@type function
@version 
@author g.sampaio
@since 12/08/2020
@return logical, retorno logico da validacao do campo
/*/
User Function UCPG47FP()

    Local cDescFPag         := ""
    Local lRetorno  		:= .T.
    Local nLinhaAtual       := 0
    Local oModel			:= FWModelActive()
    Local oView				:= FWViewActive()
    Local oModelU84			:= oModel:GetModel("U84DETAIL")

    // pega a linha atual do Modelo de dados
    nLinhaAtual     := oModelU84:GetLine()

    if nLinhaAtual > 0

        // pego a linha atual
        oModelU84:GoLine(nLinhaAtual)

        // descricao da forma de pgamento
        cDescFPag := Posicione("SX5", 1, XFILIAL("SX5") + "24" +  oModelU84:GetValue( "U84_FORMA" ), "X5_DESCRI" )

        // preencho o campo de descricao
        oModelU84:LoadValue( 'U84_DESCRI', cDescFPag )

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

    Local lRetorno      := .T.
    Local nLinhaAtual   := 0
    Local nItem         := 0
    Local nParcIniAux   := 0
    Local nParcFimAux   := 0

    // parcela inicial
    nParcIniAux := oFieldModel:GetValue("U85_PARINI")

    // parcela final
    nParcFimAux := oFieldModel:GetValue("U85_PARFIN")

    // para validar o conteudo do campo de vencimento
    If nParcIniAux == 0

        // retorno falso
        lRetorno := .F.

        // mensagem para o usuario
        oFieldModel:GetModel():SetErrorMessage('U85DETAIL', "U85_PARINI" , 'U85DETAIL' , 'U85_PARINI' , "Problema no Campo <Parc.Inicial>",;
            'O campo <Parc.Inicial> deve ser preenchido com valor maior que 0 (zero), volte ao campo e preencha o campo corretamente.' )

    EndIf

    // para validar o conteudo do campo de vencimento
    if nParcFimAux == 0

        // retorno falso
        lRetorno := .F.

        // mensagem para o usuario
        oFieldModel:GetModel():SetErrorMessage('U85DETAIL', "U85_PARFIN" , 'U85DETAIL' , 'U85_PARFIN' , "Problema no Campo <Parc.Final>",;
            'O campo <Parc.Final> deve ser preenchido com valor maior que 0 (zero), volte ao campo e preencha o campo corretamente.' )

    endIf

    // pego a linha atual
    nLinhaAtual := oFieldModel:GetLine()

    // percorro os itens do modelo de dados
    for nItem := 1 to oFieldModel:Length()

        // posiciono na linha
        oFieldModel:GoLine(nItem)

        // verifico se estou na linha diferente da atual
        if nLinhaAtual <> oFieldModel:GetLine()

            // valido se a parcela inicial esta entre a parcela inicial e final de outra linha 
            if nParcIniAux >= oFieldModel:GetValue("U85_PARINI") .And. nParcIniAux <= oFieldModel:GetValue("U85_PARFIN")
                
                // retorno negativo da validacao
                lRetorno := .F.

                // mensagem para o usuario
                oFieldModel:GetModel():SetErrorMessage('U85DETAIL', "U85_PARINI" , 'U85DETAIL' , 'U85_PARINI' , 'Problema no Campo <b>Parc.Inicial</b>',;
                    'O campo <b>Parc.Inicial</b> deve ser preenchido com um intervalo diferente do já utilizado no item: ' + oFieldModel:GetValue("U85_ITEM") )

            // valido se a parcela final esta entre a parcela inicial e final de outra linha
            elseif nParcFimAux >= oFieldModel:GetValue("U85_PARINI") .And. nParcFimAux <= oFieldModel:GetValue("U85_PARFIN")

                // retorno negativo da validacao
                lRetorno := .F.

               // mensagem para o usuario
                oFieldModel:GetModel():SetErrorMessage('U85DETAIL', "U85_PARFIN" , 'U85DETAIL' , 'U85_PARFIN' , 'Problema no Campo <b>Parc.Final</b>',;
                    'O campo <b>Parc.Final</b> deve ser preenchido com um intervalo diferente do já utilizado no item: ' + oFieldModel:GetValue("U85_ITEM") )

            endIf

        endIf

    next nItem

Return(lRetorno)

/*/{Protheus.doc} PICTENT47
Funcao para definir a picture do campo
@author g.sampaio
@since 03/09/2020
@version undefined
@param nil
@type function
@return cPicture, caracter, retorna a picture do campo
/*/

User Function PICTENT47()

    Local cPicture := ""

    If FwFldGet("U85_TIPENT") == "1" //1=Percentual
        cPicture := "@E 999.99"

    ElseIf FwFldGet("U85_TIPENT") == "2" //2=Valor em Reais
        cPicture := "@E 999,999.99"

    Else
        cPicture := "@E 999,999.99"

    EndIf

Return(cPicture)

/*/{Protheus.doc} PICTCAR47
Funcao para definir a picture do campo
@author g.sampaio
@since 03/09/2020
@version undefined
@param nil
@type function
@return cPicture, caracter, retorna a picture do campo
/*/

User Function PICTCAR47()

    Local cPicture := ""

    If FwFldGet("U85_TPCARF") == "1" //1=Percentual
        cPicture := "@E 999.99"

    ElseIf FwFldGet("U85_TPCARF") == "2" //2=Valor em Reais
        cPicture := "@E 999,999.99"

    Else
        cPicture := "@E 999,999.99"

    EndIf

Return(cPicture)

/*/{Protheus.doc} PICTDESC47
Funcao para definir a picture do campo
@author g.sampaio
@since 03/09/2020
@version undefined
@param nil
@type function
@return cPicture, caracter, retorna a picture do campo
/*/

User Function PICTDESC47()

    Local cPicture := ""

    If FwFldGet("U85_TPDESC") == "1" //1=Percentual
        cPicture := "@E 999.99"

    ElseIf FwFldGet("U85_TPDESC") == "2" //2=Valor em Reais
        cPicture := "@E 999,999.99"

    Else
        cPicture := "@E 999,999.99"

    EndIf

Return(cPicture)
