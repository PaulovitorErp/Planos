#include "totvs.ch"
#include "fwmvcdef.ch"
#include "FWEditPanel.CH"

/*/{Protheus.doc} RFUNA036
Cadastro de Plano de Seguro Mongeral
@author [tbc] g.sampaio - guilherme.sampaio@totvs.com.br
@since 21/12/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
user function RFUNA036()
Local oBrowse

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'UI2' )
oBrowse:SetDescription( 'Plano de Seguro' )
oBrowse:AddLegend("UI2_STATUS == '1'", "GREEN"  ,	"Ativo")
oBrowse:AddLegend("UI2_STATUS == '2'", "RED"    ,	"Desativado")
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Monta o menu da rotina
@author [tbc] g.sampaio - guilherme.sampaio@totvs.com.br
@since 21/12/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title 'Visualizar'  Action 'VIEWDEF.RFUNA036' OPERATION 02 ACCESS 0
ADD OPTION aRotina Title 'Incluir'     Action 'VIEWDEF.RFUNA036' OPERATION 03 ACCESS 0
ADD OPTION aRotina Title 'Alterar'     Action 'VIEWDEF.RFUNA036' OPERATION 04 ACCESS 0
ADD OPTION aRotina Title 'Excluir'     Action 'VIEWDEF.RFUNA036' OPERATION 05 ACCESS 0
ADD OPTION aRotina TITLE 'Legenda'     ACTION 'U_FUN36LEG()'     OPERATION 06 ACCESS 0
ADD OPTION aRotina Title 'Imprimir'    Action 'VIEWDEF.RFUNA036' OPERATION 08 ACCESS 0
ADD OPTION aRotina Title 'Copiar'      Action 'VIEWDEF.RFUNA036' OPERATION 09 ACCESS 0


Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

@author [tbc] g.sampaio - guilherme.sampaio@totvs.com.br
@since 21/12/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruUI2 := FWFormStruct( 1, 'UI2', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruUI3 := FWFormStruct( 1, 'UI3', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'PFUNA036', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'UI2MASTER', /*cOwner*/, oStruUI2 )

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'UI3DETAIL', 'UI2MASTER', oStruUI3, {|oMdlG,nLine,cAcao,cCampo| fBLinePre(oMdlG,nLine,cAcao,cCampo)}, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'UI3DETAIL', { { 'UI3_FILIAL', 'xFilial( "UI3" )' }, { 'UI3_CODIGO', 'UI2_CODIGO' } }, UI3->( IndexKey( 1 ) ) )

// Liga o controle de nao repeticao de linha
oModel:GetModel( 'UI3DETAIL' ):SetUniqueLine( { 'UI3_ITEM' } )

// informo a chave primaria
oModel:SetPrimaryKey( { "UI2_FILIAL", "UI2_CODIGO" } )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( 'Cadastro de Planos de Seguro - Mongeral' )

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'UI2MASTER' ):SetDescription( 'Dados da Regra' )
oModel:GetModel( 'UI3DETAIL' ):SetDescription( 'Taxas'  )

// deixo a grid como opcional
oModel:GetModel( 'UI3DETAIL' ):SetOptional( .T. ) 

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

@author [tbc] g.sampaio - guilherme.sampaio@totvs.com.br
@since 21/12/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oStruUI2 := FWFormStruct( 2, 'UI2' )
Local oStruUI3 := FWFormStruct( 2, 'UI3' )

// Cria a estrutura a ser usada na View
Local oModel   := FWLoadModel( 'RFUNA036' )
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_UI2', oStruUI2, 'UI2MASTER' )

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_UI3', oStruUI3, 'UI3DETAIL' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 60 )
oView:CreateHorizontalBox( 'INFERIOR', 40 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_UI2', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_UI3', 'INFERIOR' )

// Define campos que terao Auto Incremento
oView:AddIncrementField( 'VIEW_UI3', 'UI3_ITEM' )

// Liga a identificacao do componente
oView:EnableTitleView('VIEW_UI3','Taxas:')

// Liga a Edição de Campos na FormGrid
//oView:SetViewProperty( 'VIEW_UI3', "ENABLEDGRIDDETAIL", { 50 } )

// defino o layout da VIEW_UI2
oView:SetViewProperty( "UI2MASTER", "SETLAYOUT", { FF_LAYOUT_VERT_DESCR_TOP  , 4 } )

Return oView

/*/{Protheus.doc} fBLinePre
Funcao para validar a edicao da linha
@author [tbc] g.sampaio - guilherme.sampaio@totvs.com.br
@since 21/12/2018
@version P12
@param  oModelGrid  - Modelo de dados da grid
        nLinha      - Linha da grid
        cAcao       - Acao que esta sendo executada na grid
        cCampo      - Campo que esta usado na grid
@return nulo
/*/

Static Function fBLinePre( oModelGrid, nLinha, cAcao, cCampo  )

Local lRet          := .T.
Local oModel		:= FWModelActive()
Local cTipo         := oModel:GetValue( 'UI2MASTER', 'UI2_TIPO' )

Default nLinha      := 0
Default cAcao       := ""
Default cCampo      := ""

// para quando for inserir dados e o tipo do plano for 1 - Fixo
if cAcao == 'CANSETVALUE' .And. cTipo == "1"
    
    // retorna falso
    lRet := .F.

    Help(,,'Help',,"É permitido alterar ou incluir itens, apenas para tipos de plano <b>2- Faixa Etaria</b>!",1,0)

// para quando for retirar a delecao e for diferente do tipo do plano for 2 - Faixa Etaria
elseif cAcao == 'UNDELETE' .And. cTipo <> "2"

    // retorna falso
    lRet := .F. 
    
    // help para o usuario
    Help(,,'Help',,"É permitido restaurar os itens deletados, apenas para tipos de plano <b>2- Faixa Etaria</b>!",1,0)

endIf

Return(lRet)

/*/{Protheus.doc} RFUNA36A
validacao do campo UI2_TIPO
@author [tbc] g.sampaio - guilherme.sampaio@totvs.com.br
@since 21/12/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/

User Function RFUNA36A()

    Local aArea         := getArea()
    Local aSaveLines	:= FWSaveRows() 
    Local oModel		:= FWModelActive()
    Local oModelUI2		:= oModel:GetModel("UI2MASTER")
    Local oModelUI3		:= oModel:GetModel("UI3DETAIL")
    Local oView			:= FWViewActive()
    Local lRet          := .T.

    // quando o UI2_TIPO for diferente de 2 - faixa etaria 
    if val( oModelUI2:GetValue("UI2_TIPO") ) <> 2   
    
        // função que deleta todas as linhas do grid
	    oModelUI3:DelAllLine()

        //restauro as linhas posicionadas
        FWRestRows( aSaveLines )

        // atualizo a view
        oView:Refresh()
    
    elseIf val( oModelUI2:GetValue("UI2_TIPO") ) == 2   // caso for por faixa etaria

        // zero os valores dos campos de Taxa e Remissivo para o tipo 2 - Faixa Etaria
        oModel:GetModel("UI2MASTER"):LoadValue("UI2_TAXA", 0)
        oModel:GetModel("UI2MASTER"):LoadValue("UI2_REMISS", 0)

    endIf

    restArea( aArea )

Return(lRet)

/*/{Protheus.doc} RFUNA36B
validacao do campo UI3_IDAINI e UI3_IDAFIM
@author [tbc] g.sampaio - guilherme.sampaio@totvs.com.br
@since 21/12/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/

User Function RFUNA36B()

    Local aArea         := getArea()
    Local aSaveLines	:= FWSaveRows() 
    Local oModel		:= FWModelActive()//FWLoadModel( 'RFUNA036' )
    Local lRet          := .T.
    Local nIdaIni       := oModel:GetValue("UI3DETAIL","UI3_IDAINI")
    Local nIdaFim       := oModel:GetValue("UI3DETAIL","UI3_IDAFIM")

    // vou validar o conteudo dos campos UI3_IDAINI e UI3_IDAFIM
    if nIdaIni > 0 .and. nIdaFim > 0 .and. nIdaIni >= nIdaFim
        
        // retorna falso
        lRet := .F. 
        
        // help para o usuario
        Help(,,'Help',,'O conteúdo do campo <b>Idade Inicia (UI3_IDAINI)</b> não pode ser maior ou igual ao conteúdo do campo <b>Idade Final (UI3_IDAFIM)</b>!',1,0)

    endIf
    
    //restauro as linhas posicionadas
    FWRestRows( aSaveLines )

    restArea( aArea )

Return(lRet)

/*/{Protheus.doc} FUN36LEG
Funcao de legenda
@author g.sampaio
@since 30/11/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/

User Function FUN36LEG()
  BrwLegenda("Plano de Seguro","Legenda",{{"BR_VERDE","Ativo"},{"BR_VERMELHO","Desativado"}})
return 

/*/{Protheus.doc} ValMaxBeneficiario
Valido se o numero maximo de beneficiarios do auxilio alimenticio
e maior que o numero maximo de beneficiario do plano de seguro
@author g.sampaio
@since 29/08/2019
@version P12
@param Nao recebe parametros
@return lRetorno, logico, retorno logico da validacao
/*/

User Function ValMaxBeneficiario()

Local aArea     := GetArea()
Local aSolucao  := {}
Local lRetorno  := .T.

// valido se o numero maximo de beneficiarios do auxilio alimenticio
// e maior que o numero maximo de beneficiarios do plano
If FwFldGet("UI2_MAXALI") > FwFldGet("UI2_MAXBEN")

    // zero o array de solucao
    aSolucao := {}

    // alimento o array de solucao da funcao Help
    Aadd( aSolucao, 'Preencher o campo <b>"Max.Alimenta"</b> com valor menor ou igual a : <b>' + cValToChar( FwFldGet("UI2_MAXBEN") ) + '</b>!' )

    // help de mensagem para o usuario
	Help( ,, 'ValMaxBeneficiario',, 'O Numero maximo de beneficiarios do auxilio alimenticio <b>"Max.Alimenta"</b>' ;
    + ' não pode ser maior que o número máximo de beneficiarios do plano de seguro <b>"Max.Benefici"</b>.', 1, 0 ,; 
    Nil, Nil, Nil, Nil, Nil, aSolucao )

    // atualizo o retorno da funcao com o valor negativo
	lRetorno := .F.

EndIf

RestArea( aArea )

Return(lRetorno)