#Include "totvs.CH"
#include "topconn.ch"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWEditPanel.CH'

/*/{Protheus.doc} RCPGA034
//Rotina de Transferencia de Enderecamento
@Author Raphael Martins
@Since 10/05/2018
@Version 1.0
@Return - Sem Retorno
@Type function
/*/

User Function RCPGA034(cCodContrato)

	Local aArea 	:= GetArea()
	Local aAreaU00	:= U00->(GetArea())
	Local oBrowse	:= Nil
	Local cName 	:= Funname()

	Default cCodContrato	:= ""

	// Altero o nome da rotina para considerar o menu deste MVC
	SetFunName("RCPGA034")

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'U38' )
	oBrowse:SetDescription( 'Transferência de Endereçamento' )

	// verifico se estou na rotina de contrato
	If !Empty(cCodContrato)

		// posiciono cadastro de contrato
		U00->( DbSetOrder(1) )
		if U00->( MsSeek( xFilial("U00")+cCodContrato ) )

			// pergunto ao usuario se quer filtrar apenas os apontamentos do contrato
			If MsgYesNo("Deseja filtrar as Transferências de Endereçamento do contrato posicionado?")
				oBrowse:SetFilterDefault( "(U38_FILORI == '"+ U00->U00_MSFIL +"' .OR. U38_FILDES == '"+ U00->U00_MSFIL +"') .AND. (U38_CTRORI=='" + U00->U00_CODIGO + "' .OR. U38_CTRDES=='" + U00->U00_CODIGO + "')" ) // filtro apenas o contrato selecionado
			EndIf

		EndIf

	EndIf

	// verifico se o campo status existe
	if U38->(FieldPos("U38_STATUS")) > 0
		oBrowse:AddLegend("Empty(U38_PEDIDO) .And. U38_STATUS == '1'"	, "WHITE",		"Sem Pedido de Vendas Gerado / Endereço Reservado")
		oBrowse:AddLegend("Empty(U38_PEDIDO) .And. U38_STATUS == '2'"	, "GREEN",		"Sem Pedido de Vendas Gerado / Endereço Efetivado")
		oBrowse:AddLegend("!Empty(U38_PEDIDO) .And. U38_STATUS == '1'"	, "ORANGE",		"Com Pedido de Vendas Gerado / Endereço Reservado")
		oBrowse:AddLegend("!Empty(U38_PEDIDO) .And. U38_STATUS == '2'"	, "RED",		"Com Pedido de Vendas Gerado / Endereço Efetivado")
	else
		oBrowse:AddLegend("Empty(U38_PEDIDO)"	, "GREEN",		"Sem Pedido de Vendas Gerado")
		oBrowse:AddLegend("!Empty(U38_PEDIDO)"	, "RED",		"Com Pedido de Vendas Gerado")
	endIf

	oBrowse:Activate()

	// Retorno o nome da rotina
	SetFunName(cName)

	RestArea(aAreaU00)
	RestArea(aArea)

Return(Nil)

/*/{Protheus.doc} MenuDef
//TODO Função que cria os menus	
@author Raphael Martins
@since 10/05/2018
@version 1.0
@type function
/*/
Static Function MenuDef()

	Local aRotina 			:= {}
	Local aRotPedCli		:= {}
	Local aRotTermo			:= {}
	Local aRotServ			:= {}
	Local aRotProjeto		:= {}

	Local lTermoCustomizado	:= SuperGetMV("MV_XTERMOC", .F., .F.) 		// parametro para informar se utilizo a impressao de termos customizada
	Local lImpNotaFiscal 	:= SuperGetMV("MV_XIMPNOT",.F., .T.) 		// parametro para habilitar e desabilitar a opcao de impressao de nota
	Local lIntFieldServ		:= SuperGetMv("MV_XINTEFS",.F.,.F.)			//Parametro para habilitar integracao com o FieldService

	////////////////////////////////////////////////////
	//////// ROTINAS PARA MANUTENCAO DO SERVIÇO ////////
	////////////////////////////////////////////////////
	if ExistBlock("RCPGA34C")
		aAdd(aRotServ,{"Efetivar"	,"U_RCPGA34C()"    	, 0, 4})
	endIf

	if ExistBlock("RCPGA34D")
		Aadd(aRotServ,{"Estornar"   ,"U_RCPGA34D(U38->U38_CODIGO)" 	, 0, 4})
	endIf

	////////////////////////////////////////////////////////////////
	///////////// ROTINAS PARA MANUTENCAO DE PEDIDO CLIENTE ////////
	/////////////////////////////////////////////////////////////////
	aAdd( aRotPedCli, {"Gerar"         		,"U_RCPGA34A()"    , 0, 4})
	Aadd( aRotPedCli, {"Visualizar"    		,"U_UVirtusViewPV(U38->U38_PEDIDO)" , 0, 4} )
	Aadd( aRotPedCli, {"Alterar"     		,"U_UVirtusAlteraPV(U38->U38_PEDIDO)" 	, 0, 4} )
	aAdd( aRotPedCli, {"Excluir"      		,"U_RCPGA34B()"    , 0, 4})
	aAdd( aRotPedCli, {"Prep.Doc.Saida"		,"U_RCPGA39C(U38->U38_PEDIDO)"	, 0,4})
	Aadd( aRotPedCli, {"Excluir Doc.Saida"	,"MATA521A()"							, 0, 4} )
	Aadd( aRotPedCli, {"Transmitir Nota"	,"FISA022()"						, 0, 4} )

	If lImpNotaFiscal
		Aadd( aRotPedCli, {"Imprimir Nota"		,"U_RUTILE25()"						, 0, 4} )
	EndIf

	// verifico se o cliente optou pela customizacao de termo
	If lTermoCustomizado

		// verifico se o ponto de entrada de termo de cliente esta compilado na base do cliente
		If ExistBlock("PTERMOCLI")

			// impressão de termos customizados pelo cliente
			aadd(aRotTermo ,{"Impressao Termo","U_PTERMOCLI()", 0, 2})

		Else

			// impressão de termos pelo modelo padrão do sistema (modelo word)
			aadd(aRotTermo ,{"Impressao Termo","U_RUTILE28(U38->U38_CTRORI)", 0, 2})

		EndIf

	Else// caso nao estiver coloco a impressao de termo padrao do template (modelo word)

		// impressão de termos pelo modelo padrão do sistema (modelo word)
		aadd(aRotTermo ,{"Impressao Termo","U_RUTILE28(U38->U38_CTRORI)", 0, 2})

	EndIf

	////////////////////////////////////////////////////////////////
	///////////// INTEGRACAO COM O MODULO FIELD SERVICE		////////
	////////////////////////////////////////////////////////////////

	if lIntFieldServ
		aadd(aRotProjeto ,{"Gerar Projeto ","U_RUTILE68('C',3,U38->U38_APONTA)", 0, 2})
		aadd(aRotProjeto ,{"Visualizar Projeto ","U_RUTILE68('C',2,U38->U38_APONTA)", 0, 10})
		aadd(aRotProjeto ,{"Excluir Projeto ","U_RUTILE68('C',5,U38->U38_APONTA)", 0, 10})
	endif

	ADD OPTION aRotina Title "Pesquisar"   			Action "PesqBrw"          	OPERATION 01 ACCESS 0
	ADD OPTION aRotina Title "Visualizar"  			Action "VIEWDEF.RCPGA034" 	OPERATION 02 ACCESS 0
	ADD OPTION aRotina Title "Alterar"    			Action "VIEWDEF.RCPGA034"	OPERATION 04 ACCESS 0
	ADD OPTION aRotina Title "Excluir"    			Action "VIEWDEF.RCPGA034"	OPERATION 05 ACCESS 0
	ADD OPTION aRotina Title "Imprimir"    			Action "VIEWDEF.RCPGA034" 	OPERATION 08 ACCESS 0

	if Len(aRotServ) > 0
		ADD OPTION aRotina Title "Endereço"  			Action aRotServ	        	OPERATION 04 ACCESS 0
	endIf

	ADD OPTION aRotina Title "Pedido de Venda"  	Action aRotPedCli	        OPERATION 04 ACCESS 0
	ADD OPTION aRotina Title "Gerador de Termo"		Action aRotTermo			OPERATION 06 ACCESS 0
	ADD OPTION aRotina Title "Legenda"     			Action "U_RCPGA34LEG()" 	OPERATION 10 ACCESS 0

	If ExistBlock("PERECOSCEM")
		ADD OPTION aRotina Title "Recibo"		Action "U_PERECOSCEM(U38->U38_APONTA)"			OPERATION 06 ACCESS 0
	EndIf

	if lIntFieldServ
		ADD OPTION aRotina Title "Projeto x Tarefas"    Action aRotProjeto		OPERATION 10 ACCESS 0
	endif


Return(aRotina)

/*/{Protheus.doc} ModelDef
//TODO Função que cria o objeto model	
@author Raphael Martins
@since 03/04/2018
@version 1.0
@type function
/*/

Static Function ModelDef()

	Local oStruU38 := FWFormStruct( 1, 'U38', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oModel

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( 'PCPGA034', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	// Crio a Enchoice com os campos da taxa
	oModel:AddFields( 'U38MASTER', /*cOwner*/, oStruU38 )

	// Adiciona a chave primaria da tabela principal
	oModel:SetPrimaryKey({ "U38_FILIAL" , "U38_CODIGO" })

	// Preencho a descrição da entidade
	oModel:GetModel('U38MASTER'):SetDescription('Dados da Transferência')

Return(oModel)

/*/{Protheus.doc} ViewDef
//TODO Função que cria o objeto View	
@author Raphael Martins
@since 03/04/2018
@version 1.0
@return object, objeto do modelo de dados
@type function
/*/
Static Function ViewDef()

	Local oView		:= NIL
	Local oStruU38 	:= FWFormStruct(2,'U38')
	Local oModel   	:= FWLoadModel('RCPGA034')

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel(oModel)

	oView:AddField('VIEW_U38'	, oStruU38	, 'U38MASTER') // cria o cabeçalho

	// Crio os Panel's horizontais
	oView:CreateHorizontalBox('PANEL_TELA'		, 100)

	// Relaciona o ID da View com os panel's
	oView:SetOwnerView('VIEW_U38' 	, 'PANEL_TELA')

	// Ligo a identificacao do componente
	oView:EnableTitleView('VIEW_U38')

	//defino quantos campos por linha serao apresentados
	oView:SetViewProperty( "U38MASTER", "SETLAYOUT", {  FF_LAYOUT_VERT_DESCR_TOP   , 2 , 10 } )

	oView:SetViewProperty("U38MASTER", "SETCOLUMNSEPARATOR", {90})

	// Define fechamento da tela ao confirmar a operação
	oView:SetCloseOnOk({||.T.})

	// Habilito a barra de progresso na abertura da tela
	oView:SetProgressBar(.T.)

Return(oView)


/*/{Protheus.doc} URetAgreg
//Funcao para retornar os agregados
do contrato Origem
@author Raphael Martins
@since 14/05/2018
@version 1.0
@return character, cAgregados - Agregados do Contrato posicionado
@type function
/*/
User Function URetAgreg()

	Local aArea			:= GetArea()
	Local aAreaU38		:= U38->(GetArea())
	Local aAreaU00		:= U00->(GetArea())
	Local cAgregados	:= ""

	U02->(DbSetOrder(1)) //U02_FILIAL + U02_CODIGO + U02_ITEM

	if U02->(DbSeek(xFilial("U02")+U00->U00_CODIGO))

		While U02->(!Eof()) .And. U02->U02_CODIGO == U00->U00_CODIGO

			cAgregados += U02->U02_ITEM + "=" + Alltrim(U02->U02_NOME) + ";"

			U02->(DbSkip())
		EndDo

	endif


	RestArea(aArea)
	RestArea(aAreaU38)
	RestArea(aAreaU00)

Return(cAgregados)

/*/{Protheus.doc} VldSrvDes
//Funcao para validacao do campo
de Servico de Destino
@author Raphael Martins
@since 16/05/2018
@version 1.0
@return logical, lRet - Continua ou nao edicao da grid
@type function
/*/ 
User Function VldSrvDes()

	Local aArea			:= GetArea()
	Local aAreaU37		:= U37->(GetArea())
	Local oModel		:= FWModelActive()
	Local oView			:= FWViewActive()
	Local oModelU38 	:= oModel:GetModel("U38MASTER")
	Local cFilDes		:= oModelU38:GetValue("U38_FILDES")
	Local cContrato		:= oModelU38:GetValue("U38_CTRDES")
	Local cServico		:= oModelU38:GetValue("U38_SERVDE")
	Local cTabelaPreco	:= SuperGetMv("MV_XTABPAD",.F.,"001")
	Local cFilBkp		:= cFilAnt
	Local lRet			:= .T.

	//altero a filial para filial de destino
	cFilAnt := cFilDes

	SB1->(DbSetOrder(1)) //B1_FILIAL + B1_COD
	if SB1->(DbSeek(xFilial("SB1")+cServico))

		U37->(DbSetOrder(2)) //U37_FILIAL+U37_CODIGO+U37_SERVIC

		//Valida saldo do produto para o contrato
		if U37->(DbSeek(xFilial("U37") + cContrato + cServico))

			if U37->U37_SALDO == 0

				Help(,,'Help',,"Servico selecionado não possui saldo no contrato !",1,0)
				lRet:= .F.

				//valido se o servico possui tabela de preco
			elseif U_RetPrecoVenda(cTabelaPreco,cServico) == 0

				Help(,,'Help',,"Servico selecionado não possui preco vigente, favor verifique a tabela de preço!",1,0)
				lRet:= .F.

			else

				FwFldPut("U38_DESSVD" ,SB1->B1_DESC,,,,.T.)
				FwFldPut("U38_QDDEST" ,"",,,,.T.)
				FwFldPut("U38_MDDEST" ,"",,,,.T.)
				FwFldPut("U38_JZDEST" ,"",,,,.T.)
				FwFldPut("U38_GVDEST" ,"",,,,.T.)
				FwFldPut("U38_CRDEST" ,"",,,,.T.)
				FwFldPut("U38_NCDEST" ,"",,,,.T.)
				FwFldPut("U38_OSDEST" ,"",,,,.T.)
				FwFldPut("U38_NODEST" ,"",,,,.T.)

				oView:Refresh()

			endif

		else

			Help(,,'Help',,"Serviço Selecionado não habilitado para o contrato, verifique os serviços do contrato!",1,0)
			lRet := .F.

		endif

	elseif !Empty(cServico)

		Help(,,'Help',,"Serviço Selecionado inválido, verifique o cadastro de produtos!",1,0)
		lRet := .F.

	endif

	//restauro a filial logada
	cFilAnt := cFilBkp

	RestArea(aAreaU37)
	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} 
//Funcao para definicao do Modo de Edicao
dos campos de Enderecamento
@author Raphael Martins 
@since 11/02/2020
@version 1.0
@param Nao recebe parametros            
@return lRet - Ativa ou nao o campo 
/*/

User Function UWhenU38()

	Local lRetorno		:= .F.
	Local cFieldEnd		:= ReadVar()
	Local oModel 		:= FWModelActive()
	Local oModelU38		:= oModel:GetModel( 'U38MASTER' )
	Local cServico 		:= oModelU38:GetValue("U38_SERVDE")
	Local cTpTransf		:= oModelU38:GetValue("U38_TPTRAN")
	Local cStatusEnd	:= if(U38->(FieldPos("U38_STATUS")) > 0, oModelU38:GetValue('U38_STATUS'), "")

	//nao permito alterar os campos de endereco para apontamento finalizado
	if INCLUI .Or. (ALTERA .And. (cStatusEnd == "1" .Or. Empty(cStatusEnd)))

		if !Empty(cServico) .And. cTpTransf == "I"

			SB1->(DbSetOrder(1)) //B1_FILIAL + B1_COD

			if SB1->(DbSeek(xFilial("SB1") + cServico))

				//verifico se servico selecionado exige definicao de endereco
				if !Empty(SB1->B1_XREQSER)

					//ENDERECO DE JAZIGO HABILITO O CAMPO UJV_QUADRA
					if SB1->B1_XREQSER == "J" .And. cFieldEnd == "M->U38_QDDEST"

						lRetorno := .T.

						//ENDERECO DE CREMACAO HABILITO O CAMPO UJV_CREMAT
					elseif SB1->B1_XREQSER == "C" .And. cFieldEnd == "M->U38_CRDEST"

						lRetorno := .T.

						//ENDERECO DE OSSARIO HABILITO O CAMPO UJV_OSSARI
					elseif SB1->B1_XREQSER == "O" .And. cFieldEnd == "M->U38_OSDEST"

						lRetorno := .T.

						//ENDERECO DE OSSARIO HABILITO O CAMPO UJV_OSSARI
					elseif SB1->B1_XREQSER == "O" .And. cFieldEnd == "M->U38_LACDST"

						lRetorno := .T.

					endif

				endif

			endif

		elseIf cFieldEnd == "M->U38_FILDES" .And. FWFldGet("U38_TPTRAN") == 'I'

			lRetorno := .T.

		elseIf cFieldEnd == "M->U38_CTRDES" .And. !Empty(FWFldGet("U38_FILDES")) .And. FWFldGet("U38_TPTRAN") == 'I'

			lRetorno := .T.

		elseif cFieldEnd == "M->U38_SERVDE" .And. FWFldGet("U38_TPTRAN") $ 'I/E'

			lRetorno := .T.

		endIf

	endif

Return(lRetorno)

/*/{Protheus.doc} 
//Funcao papara validar o campo filial
destino
dos campos de Enderecamento
@author Raphael Martins 
@since 11/02/2020
@version 1.0
@param Nao recebe parametros            
@return lRet 
/*/
User Function UVldFilDest()

	Local aArea 		:= GetArea()
	Local aDadosFilial	:= {}
	Local oModel 		:= FWModelActive()
	Local oModelU38		:= oModel:GetModel( 'U38MASTER' )
	Local cFilDest 		:= oModelU38:GetValue("U38_FILDES")
	Local lRet 			:= .T.

	//retorno os dados da filial
	aDadosFilial := FWSM0Util():GetSM0Data( cEmpAnt , cFilDest , { "M0_CODFIL" } )

	//valido se a filial existe
	if Ascan(aDadosFilial,{|x| AllTrim(x[2]) == Alltrim(cFilDest) }) > 0

		FwFldPut("U38_CTRDES" ,"",,,,.T.)
		FwFldPut("U38_DESSVD" ,"",,,,.T.)
		FwFldPut("U38_QDDEST" ,"",,,,.T.)
		FwFldPut("U38_MDDEST" ,"",,,,.T.)
		FwFldPut("U38_JZDEST" ,"",,,,.T.)
		FwFldPut("U38_GVDEST" ,"",,,,.T.)
		FwFldPut("U38_CRDEST" ,"",,,,.T.)
		FwFldPut("U38_NCDEST" ,"",,,,.T.)
		FwFldPut("U38_OSDEST" ,"",,,,.T.)
		FwFldPut("U38_NODEST" ,"",,,,.T.)

	else

		lRet := .F.
		Help( ,, 'Help',, 'Filial Informada inválida!', 1, 0 )

	endif

	RestArea(aArea)

Return(lRet)


/*/{Protheus.doc} UVldCtrDest
//Funcao para validar o contrato destino
@author Raphael Martins 
@since 11/02/2020
@version 1.0
@param Nao recebe parametros            
@return lRet - Ativa ou nao o campo 
/*/
User Function UVldCtrDest()

	Local aArea 		:= GetArea()
	Local oModel 		:= FWModelActive()
	Local oModelU38		:= oModel:GetModel( 'U38MASTER' )
	Local cFilDest 		:= oModelU38:GetValue("U38_FILDES")
	Local cContrato		:= oModelU38:GetValue("U38_CTRDES")
	Local FilBkp		:= cFilAnt
	Local lRet 			:= .T.

//altero a filial logada para a filial destino 
	cFilAnt := Alltrim(cFilDest)

	U00->(DbSetOrder(1)) //U00_FILIAL + U00_CODIGO

	if U00->(DbSeek(xFilial("U00") + cContrato ))

		FwFldPut("U38_DESSVD" ,"",,,,.T.)
		FwFldPut("U38_QDDEST" ,"",,,,.T.)
		FwFldPut("U38_MDDEST" ,"",,,,.T.)
		FwFldPut("U38_JZDEST" ,"",,,,.T.)
		FwFldPut("U38_GVDEST" ,"",,,,.T.)
		FwFldPut("U38_CRDEST" ,"",,,,.T.)
		FwFldPut("U38_NCDEST" ,"",,,,.T.)
		FwFldPut("U38_OSDEST" ,"",,,,.T.)
		FwFldPut("U38_NODEST" ,"",,,,.T.)

	else

		lRet := .F.
		Help( ,, 'Help',, 'Contrato inválido na filial de destino!', 1, 0 )

	endif

//Restauro a filial logada
	cFilAnt := FilBkp

	RestArea(aArea)

Return(lRet)


/*/{Protheus.doc} UVldItemOrg
//Funcao para validar o item origem da transferencia de enderecamento
@author Raphael Martins 
@since 11/02/2020
@version 1.0
@param Nao recebe parametros            
@return lRet - Ativa ou nao o campo 
/*/
User Function UVldItemOrg()

	Local aArea 		:= GetArea()
	Local oModel 		:= FWModelActive()
	Local oModelU38		:= oModel:GetModel( 'U38MASTER' )
	Local cItemSel 		:= oModelU38:GetValue("U38_ITEMEN")
	Local cContrato 	:= oModelU38:GetValue("U38_CTRORI")
	Local lValPrazoExu	:= SuperGetMv("MV_XVLDEXU",,.F.)
	Local lRetorno		:= .T.

	U04->(DBSetOrder(1)) // U04_FILIAL+U04_CODIGO+U04_ITEM

	if !Empty(cItemSel) .And. U04->(DbSeek(xFilial("U04") + cContrato + cItemSel))

		// verifico se o sistema esta validando o prazo de exumacao na transferencia
		if lValPrazoExu

			// caso o prazo de exumacao for maior que a data base nao faco a transferencia de endereços
			if U04->U04_PRZEXU > dDatabase

				lRetorno := .F.
				Help( ,, 'Help - Prazo de Exumação',, 'Não é possível realizar a transferência deste endereço, pois a data base ainda não alcançou a data permitida para exumação do sepultado - Data do Prazo de Exumação: '+ Dtoc(U04->U04_PRZEXU) +'!', 1, 0 )

			endIf

		endIf

		// verifico se devo continuar
		if lRetorno

			oModelU38:LoadValue("U38_ITEMEN"	, cItemSel )
			oModelU38:LoadValue("U38_QUADRA"	, U04->U04_QUADRA)
			oModelU38:LoadValue("U38_MODULO"	, U04->U04_MODULO)
			oModelU38:LoadValue("U38_JAZIGO"	, U04->U04_JAZIGO)
			oModelU38:LoadValue("U38_GAVETA"	, U04->U04_GAVETA)
			oModelU38:LoadValue("U38_OSSARI"	, U04->U04_OSSARI)
			oModelU38:LoadValue("U38_NICHOO"	, U04->U04_NICHOO)
			oModelU38:LoadValue("U38_DTSERV"	, U04->U04_DATA)
			oModelU38:LoadValue("U38_DTUTIL"	, U04->U04_DTUTIL)
			oModelU38:LoadValue("U38_QUEMUT"	, U04->U04_QUEMUT)
			oModelU38:LoadValue("U38_PRZEXU"	, U04->U04_PRZEXU)
			oModelU38:LoadValue("U38_QDDEST"	, "")
			oModelU38:LoadValue("U38_MDDEST"	, "")
			oModelU38:LoadValue("U38_JZDEST"	, "")
			oModelU38:LoadValue("U38_GVDEST"	, "")
			oModelU38:LoadValue("U38_CRDEST"	, "")
			oModelU38:LoadValue("U38_NCDEST"	, "")
			oModelU38:LoadValue("U38_OSDEST"	, "")
			oModelU38:LoadValue("U38_NODEST"	, "")
			oModelU38:LoadValue("U38_PRZEXU"	, "")

		endIf

	else

		lRetorno := .F.
		Help( ,, 'Help',, 'Item Selecionado inválido, verifique se existe esse apontamento no contrato!', 1, 0 )

	endif

	RestArea(aArea)

Return(lRetorno)

/*/{Protheus.doc} RCPGA34A
Funcao para Preparar os Dados para gerar
o pedido de venda
@type function
@version 
@author Raphael Martins
@since 02/03/2020
@return return_type, return_description
/*/
User Function RCPGA34A()

	Local aArea 	:= GetArea()
	Local aAreaU38	:= U38->(GetArea())
	Local aAreaUJV	:= UJV->(GetArea())
	Local lRet 		:= .T.
	Local cFilBkp	:= cFilAnt
	Local cContrato	:= ""
	Local cServico	:= ""
	Local cPedido	:= ""

	// valido se nao existe pedido de vendas gerado
	if Empty(U38->U38_PEDIDO)

		cFilAnt 	:= Alltrim(U38->U38_FILDES)
		cContrato	:= U38->U38_CTRDES
		cServico	:= U38->U38_SERVDE

		U00->(DbSetOrder(1)) //U00_FILIAL + U00_CODIGO

		if U00->(DbSeek(xFilial("U00")+cContrato))

			if !Empty(U00->U00_CLIENT) .And. !Empty(U00->U00_LOJA)

				if MsgYesNo("Deseja Gerar o Pedido de Venda da Transferência de Endereço selecionado!")

					FWMsgRun(,{|oSay| cPedido := U_PCPGA34A(cContrato,cServico,U38->U38_CODIGO) },'Aguarde...','Gerando Pedido de Venda da Transferência de Endereço!')

					if !Empty(cPedido)

						MsgInfo("Pedido de Venda: " + cPedido + " gerado com sucesso!" )

					endif

				endif

			else

				lRet := .F.
				Help( ,, 'Help',, 'Favor preencher os campos de cliente e condição de pagamento para geração do pedido!', 1, 0 )


			endif

		else

			lRet := .F.
			Help( ,, 'Help',, 'Contrato de Destino da Transferencia não encontrado!', 1, 0 )

		endif

	else

		lRet := .F.
		Help( ,, 'Help',, 'Apontamento selecionado já possui pedido de venda relacionado!', 1, 0 )

	endif

	//Restauro a filial logada
	cFilAnt := cFilBkp

	RestArea(aAreaUJV)
	RestArea(aAreaU38)
	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} RCPGA34LEG
Funcao de legenda da transferencia de endereçamento
@type function
@version 
@author g.sampaio
@since 11/11/2020
@return nil
/*/
User Function RCPGA34LEG()

	BrwLegenda("Status do Apontamento","Legenda",{;
		{"BR_BRANCO"	,"Sem Pedido de Vendas Gerado / Endereço Reservado"},;
		{"BR_VERDE"		,"Sem Pedido de Vendas Gerado / Endereço Efetivado"},;
		{"BR_LARANJA"	,"Com Pedido de Vendas Gerado / Endereço Reservado"},;
		{"BR_VERMELHO"	,"Com Pedido de Vendas Gerado / Endereço Efetivado"}})

Return(Nil)

/*/{Protheus.doc} RCPGA34B
Funcao para EXCLUIR o Pedido de Venda
do Apontamento Cemiterio
@type function
@version 1.0
@author g.sampaio
@since 10/03/2021
@return logical, retorna se deu tudo certo
/*/
User Function RCPGA34B()

	Local aArea		:= GetArea()
	Local aAreaU38	:= U38->(GetArea())
	Local aAreaUJV	:= UJV->(GetArea())
	Local lRetorno	:= .T.

	if !Empty(U38->U38_PEDIDO)

		If AllTrim(U38->U38_PEDIDO) == "PVAPONT" // pedido de venda gerado pelo apontamento

			lRetorno := .F.
			MSgAlert("Pedido de venda gerado pelo apontamento de serviços!")

		Elseif MsgYesNo("Deseja excluir o Pedido de Venda do Apontamento selecionado!")

			FWMsgRun(,{|oSay| lRetorno := U_EstornaLibPedido(U38->U38_PEDIDO)},'Aguarde...','Estornando Pedido de Venda da Transferencia!')

			//Atualiza status
			if lRetorno

				U38->(RecLock("U38",.F.))
				U38->U38_PEDIDO := ""
				U38->(MsUnlock())

				if Empty(U38->U38_APONTA)

					UJV->(DbSetOrder(1))
					if UJV->(MsSeek(xFilial("UJV")+U38->U38_APONTA))

						UJV->(RecLock("UJV",.F.))

						UJV->UJV_PEDIDO := ""
						UJV->UJV_STATUS := "E"

						UJV->(MsUnlock())

					endIf

					MsgInfo("Pedido de Venda excluído com sucesso!")

				endif

			endif
		else
			Alert("Operacao abortada pelo usuário!")
		endIf

	else

		lRetorno := .F.
		Help( ,, 'Help',, 'Apontamento não possui pedido gerado!', 1, 0 )

	endif

	RestArea(aAreaUJV)
	RestArea(aAreaU38)
	RestArea(aArea)

Return(lRetorno)

/*/{Protheus.doc} RCPGA34C
Funcao para realizar as transferencias dos 
enderecos selecionados
@type function
@version 1.0
@author Raphael Martins 
@since 17/05/2018
@param oModelTransf, object, objeto de dados da transferencia
@return logical, retorno sobre a confirmacao da transferencia
/*/
User Function RCPGA34C(oModelTransf)

	Local aAptServico		:= {}
	Local lRetorno			:= .T.
	Local lPrevio			:= .F.
	Local cCodAptServic		:= ""
	Local cTabPad			:= SuperGetMv("MV_XTABPAD",,"001")
	Local cPedido			:= ""
	Local cFilBkp			:= cFilAnt
	Local oModelU38			:= Nil
	Local cContrato			:= ""
	Local dDataTransf		:= ""
	Local cTpTransf			:= ""
	Local cFilOrig			:= ""
	Local cFilDes			:= ""
	Local cCtrDes			:= ""
	Local cAutorizad		:= ""
	Local cItemOrig			:= ""
	Local cServico			:= ""
	Local cQuadDest			:= ""
	Local cModuDest			:= ""
	Local cJaziDest			:= ""
	Local cGaveDest			:= ""
	Local cCremDest			:= ""
	Local cNichoCDest		:= ""
	Local cOssarDest		:= ""
	Local cNichoODest		:= ""
	Local cObservacao		:= ""
	Local cLacreOss			:= ""
	Local dDtObtAptOld		:= Stod("")
	Local dDtCertAptOld		:= Stod("")
	Local dDtNascAptOld		:= Stod("")
	Local dDataPrevio		:= Stod("")
	Local cLocFalAptOld		:= ""
	Local cSexoAptOld		:= ""
	Local cEstCivilAptOld	:= ""
	Local cNomeMae			:= ""
	Local nAnosExu			:= SuperGetMv("MV_XANOSEX",.F.,5)
	Local lAtivJazOssi  	:= SuperGetMV("MV_XJAZOSS",,.F.)

	if ValType( oModelTransf ) == "O"
		oModelU38	:= oModelTransf

		cContrato		:= oModelU38:GetValue('U38_CTRORI')
		dDataTransf		:= oModelU38:GetValue('U38_DATA')
		cTpTransf		:= oModelU38:GetValue('U38_TPTRAN')
		cFilOrig		:= oModelU38:GetValue('U38_FILORI')
		cFilDes			:= oModelU38:GetValue('U38_FILDES')
		cCtrDes			:= oModelU38:GetValue('U38_CTRDES')
		cAutorizad		:= oModelU38:GetValue('U38_AUTORI')
		cItemOrig		:= oModelU38:GetValue('U38_ITEMEN')
		cServico		:= oModelU38:GetValue('U38_SERVDE')
		cQuadDest		:= oModelU38:GetValue('U38_QDDEST')
		cModuDest		:= oModelU38:GetValue('U38_MDDEST')
		cJaziDest		:= oModelU38:GetValue('U38_JZDEST')
		cGaveDest		:= oModelU38:GetValue('U38_GVDEST')
		cCremDest		:= oModelU38:GetValue('U38_CRDEST')
		cNichoCDest		:= oModelU38:GetValue('U38_NCDEST')
		cOssarDest		:= oModelU38:GetValue('U38_OSDEST')
		cNichoODest		:= oModelU38:GetValue('U38_NODEST')
		cObservacao		:= oModelU38:GetValue('U38_OBSERV')
		cLacreOss		:= if(U38->(FieldPos("U38_LACDST")) > 0, oModelU38:GetValue('U38_LACDST'), "")
		cStatus			:= if(U38->(FieldPos("U38_STATUS")) > 0, oModelU38:GetValue('U38_STATUS'), "")

	else

		cContrato		:= U38->U38_CTRORI
		dDataTransf		:= U38->U38_DATA
		cTpTransf		:= U38->U38_TPTRAN
		cFilOrig		:= U38->U38_FILORI
		cFilDes			:= U38->U38_FILDES
		cCtrDes			:= U38->U38_CTRDES
		cAutorizad		:= U38->U38_AUTORI
		cItemOrig		:= U38->U38_ITEMEN
		cServico		:= U38->U38_SERVDE
		cQuadDest		:= U38->U38_QDDEST
		cModuDest		:= U38->U38_MDDEST
		cJaziDest		:= U38->U38_JZDEST
		cGaveDest		:= U38->U38_GVDEST
		cCremDest		:= U38->U38_CRDEST
		cNichoCDest		:= U38->U38_NCDEST
		cOssarDest		:= U38->U38_OSDEST
		cNichoODest		:= U38->U38_NODEST
		cObservacao		:= U38->U38_OBSERV
		cLacreOss		:= if(U38->(FieldPos("U38_LACDST")) > 0, U38->U38_LACDST, "")
		cStatus			:= if(U38->(FieldPos("U38_STATUS")) > 0, U38->U38_STATUS, "")

	endIf

	// status reservado
	if cStatus == "1" .Or. Empty(cStatus)

		U04->(DbSetOrder(1)) // U04_FILIAL + U04_CODIGO + U04_ITEM
		SB1->(DbSetOrder(1)) // B1_FILIAL + B1_COD

		if U04->(MsSeek(xFilial("U04") + cContrato + cItemOrig ))

			if U04->U04_PREVIO == "S"
				dDataPrevio := U04->U04_DATA
				lPrevio 	:= .T.
			endIf

			BEGIN TRANSACTION

				cProxItemU30 := MaxItemU30(cContrato)

				//envio o endereco atual para o historico e deleto o mesmo da U04 - Enderecamento
				RecLock("U30",.T.)

				U30->U30_FILIAL 	:= U04->U04_FILIAL
				U30->U30_CODIGO 	:= U04->U04_CODIGO
				U30->U30_ITEM		:= cProxItemU30
				U30->U30_ITGAVE		:= U04->U04_ITEM
				U30->U30_QUADRA 	:= U04->U04_QUADRA
				U30->U30_MODULO 	:= U04->U04_MODULO
				U30->U30_JAZIGO 	:= U04->U04_JAZIGO
				U30->U30_GAVETA 	:= U04->U04_GAVETA
				U30->U30_CREMAT		:= U04->U04_CREMAT
				U30->U30_NICHOC		:= U04->U04_NICHOC
				U30->U30_OSSARI 	:= U04->U04_OSSARI
				U30->U30_NICHOO		:= U04->U04_NICHOO

				if U30->(FieldPos("U30_ORIGEM")) > 0
					U30->U30_ORIGEM	:= "RCPGA034"
				endIf

				if U30->(FieldPos("U30_CODORI")) > 0
					U30->U30_CODORI	:= U38->U38_CODIGO
				endIf

				// verifico se os campos estão criados
				if U04->(FieldPos("U04_LACOSS")) > 0 .And. U30->(FieldPos("U30_LACOSS")) > 0
					U30->U30_LACOSS		:= U04->U04_LACOSS
				endIf

				U30->U30_DTUTIL 	:= U04->U04_DTUTIL
				U30->U30_QUEMUT 	:= U04->U04_QUEMUT
				U30->U30_RECU04		:= U04->(Recno())
				U30->U30_TRANSF		:= "S" //transferencia
				U30->U30_DTHIST 	:= dDataTransf
				U30->U30_APONTA		:= U04->U04_APONTA

				U30->(MsUnlock())

				// posiciono no apontamento, caso houver preenchido
				UJV->(DbSetOrder(1))
				if UJV->(MsSeek(xFilial("UJV")+U04->U04_APONTA))
					dDtObtAptOld	:= UJV->UJV_DTOBT
					dDtCertAptOld	:= UJV->UJV_DTCERT
					dDtNascAptOld	:= UJV->UJV_DTNASC
					cLocFalAptOld	:= UJV->UJV_LOCFAL
					cSexoAptOld		:= UJV->UJV_SEXO
					cEstCivilAptOld	:= UJV->UJV_ESTCIV
					cNomeMae		:= UJV->UJV_NOMAE

				EndIf

				// posiciono no cadastro de produtos
				if SB1->(MsSeek(xFilial("SB1")+ cServico ))

					// ==============================================================
					// inicio o apontamento de sevico da transferencia de enderecos
					// ===============================================================

					cCodAptServic	:= GetSXENum("UJV","UJV_CODIGO")

					// vou gerar o apontamento de servicos
					aadd(aAptServico,{"UJV_FILIAL"		, xFilial("UJV")		})
					aadd(aAptServico,{"UJV_CODIGO"		, cCodAptServic			})
					aadd(aAptServico,{"UJV_CONTRA"		, cContrato				})
					aadd(aAptServico,{"UJV_SERVIC"		, cServico				})

					// pego os dados do contrato
					U00->(DbSetOrder(1))
					if U00->(MsSeek( xFilial("U00")+cContrato ))
						aadd(aAptServico,{"UJV_CODCLI"		, U00->U00_CLIENT			})
						aadd(aAptServico,{"UJV_LOJCLI"		, U00->U00_LOJA				})
					endIf

					aadd(aAptServico,{"UJV_AUTORI"		, cAutorizado			})
					aadd(aAptServico,{"UJV_USRATE"		, cUserName				})
					aadd(aAptServico,{"UJV_DATA"		, dDataTransf			})
					aadd(aAptServico,{"UJV_HORA"		, SubStr(Time(),1,5)	})
					aadd(aAptServico,{"UJV_DTSEPU"		, dDataTransf			})
					aadd(aAptServico,{"UJV_HORASE"		, SubStr(Time(),1,5)	})
					aadd(aAptServico,{"UJV_TABPRC"		, cTabPad				})
					aadd(aAptServico,{"UJV_OBS"			, cObservacao			})
					aadd(aAptServico,{"UJV_DTOBT"		, dDtObtAptOld			})
					aadd(aAptServico,{"UJV_DTCERT"		, dDtCertAptOld			})
					aadd(aAptServico,{"UJV_LOCFAL"		, cLocFalAptOld			})
					aadd(aAptServico,{"UJV_NOME"		, U04->U04_QUEMUT		})
					aadd(aAptServico,{"UJV_DTNASC"		, dDtNascAptOld			})
					aadd(aAptServico,{"UJV_SEXO"		, cSexoAptOld			})
					aadd(aAptServico,{"UJV_ESTCIV"		, cEstCivilAptOld		})
					aadd(aAptServico,{"UJV_NOMAE"		, cNomeMae				})

					if SB1->B1_XREQSER == "J"// Jazigo
						aadd(aAptServico,{"UJV_QUADRA"		, cQuadDest		}) // quadra destino
						aadd(aAptServico,{"UJV_MODULO"		, cModuDest 	}) // modulo destino
						aadd(aAptServico,{"UJV_JAZIGO"		, cJaziDest		}) // jazigo destino
						aadd(aAptServico,{"UJV_GAVETA"		, cGaveDest		}) // gaveta destino

					elseIf SB1->B1_XREQSER == "C"// Crematorio
						aadd(aAptServico,{"UJV_CREMAT"		, cCremDest		}) // crematorio destino
						aadd(aAptServico,{"UJV_NICHOC"		, cNichoCDest	}) // nicho crematorio destino

					elseIf SB1->B1_XREQSER == "O"// Ossario
						aadd(aAptServico,{"UJV_OSSARI"		, cOssarDest	}) // ossario destino
						aadd(aAptServico,{"UJV_NICHOO"		, cNichoODest	}) // nicho ossario destino

						// verifico se o campo lacre existe
						if UJV->(FieldPos("UJV_LACOSS")) > 0
							aadd(aAptServico,{"UJV_LACOSS"		, cLacreOss			})
						endIf

					endIf

					aadd(aAptServico,{"UJV_ORIGEM"		, "RCPGA034"	})

				endIf

				// executo o execauto de apontamento de servicos
				if Len(aAptServico) > 0

					// execauto de apotnamento de servicos cemiterio
					lRetorno := U_RCPGE056( 3, aAptServico)

					// verifico se deu certo
					if lRetorno

						UJV->(ConfirmSX8()) // confirmo o controle de numeracao

						if UJV->(Reclock("UJV",.F.))
							UJV->UJV_STATUS := "F" // gravo status do endereco como efetivado
							UJV->UJV_STENDE := "E" // gravo status do endereco como efetivado
							UJV->(MsUnlock())
						else
							UJV->(DisarmTransaction())
						endIf

					else
						UJV->(RollBackSX8())// desfaco o controle de numeracao

					endIf

				else
					lRetorno := .F.

				endIf

				// ==============================================================
				// fim o apontamento de sevico da transferencia de enderecos
				// ===============================================================

				// verifico se esta tudo certo ate aqui
				if lRetorno

					// quando for enderecamento previo e o contrato for diferente e a gaveta for 01
					if lPrevio .And. ((U04->U04_TIPO == "J" .And. cContrato  <> cCtrDes) .Or. SB1->B1_XREQSER <> "J")

						RefazEndPrevio(U04->(Recno()))

					else

						// deleto o registro da U04
						RecLock("U04",.F.)
						U04->(DbDelete())
						U04->(MsUnlock())

					endIf

					///////////////////////////////////////////////////////
					///////////// TRANSFERENCIA INTERNA    ///////////////
					//////////////////////////////////////////////////////
					if cTpTransf == "I"

						//altero a filial logada de acordo com a filial de destino
						cFilAnt := cFilDes

						SB1->(DbSetOrder(1))
						if SB1->(MsSeek(xFilial("SB1")+ cServico ))

							cNextU04 := U_NextU04(cCtrDes)

							RecLock("U04",.T.)

							U04->U04_FILIAL := xFilial("U04")
							U04->U04_CODIGO := cCtrDes
							U04->U04_ITEM	:= cNextU04
							U04->U04_DTUTIL	:= dDataTransf
							U04->U04_QUEMUT	:= U38->U38_QUEMUT

							if lPrevio .And. SB1->B1_XREQSER == "J"
								U04->U04_DATA	:= dDataPrevio
								U04->U04_PREVIO	:= "S"
							else
								U04->U04_DATA	:= dDataTransf
								U04->U04_PREVIO	:= "N"
							endIf

							///////////////////////////////////////////////////////
							///////// 		ENDERECO DE GAVETA			///////////
							///////////////////////////////////////////////////////
							if SB1->B1_XREQSER == "J"

								U04->U04_TIPO	:= "J"
								U04->U04_QUADRA := U38->U38_QDDEST
								U04->U04_MODULO := U38->U38_MDDEST
								U04->U04_JAZIGO := U38->U38_JZDEST
								U04->U04_GAVETA := U38->U38_GVDEST
								U04->U04_LOCACA	:= SB1->B1_XLOCACA

								U04->U04_OCUPAG	:= SB1->B1_XOCUGAV

								//ocupa gaveta
								if SB1->B1_XOCUGAV == 'S'

									U04->U04_OCUPAG := SB1->B1_XOCUGAV
									U04->U04_PRZEXU	:= YearSum(dDatabase,nAnosExu)

								else

									U04->U04_PRZEXU	:= U38->U38_PRZEXU

								endif

								///////////////////////////////////////////////////////
								///////// 		ENDERECO DE CREMACAO		///////////
								///////////////////////////////////////////////////////
							elseif SB1->B1_XREQSER == "C"

								U04->U04_TIPO	:= "C"
								U04->U04_CREMAT := U38->U38_CRDEST
								U04->U04_NICHOC	:= U38->U38_NCDEST

								///////////////////////////////////////////////////////
								///////// 		ENDERECO DE CREMACAO		///////////
								///////////////////////////////////////////////////////
							elseif SB1->B1_XREQSER == "O"

								U04->U04_TIPO	:= "O"
								U04->U04_OSSARI := U38->U38_OSDEST
								U04->U04_NICHOO	:= U38->U38_NODEST
								U04->U04_LACOSS	:= cLacreOss

								if lAtivJazOssi

									U13->(DbSetOrder(1))
									if U13->(MsSeek(xFilial("U13")+U38->U38_OSDEST))

										if !Empty(U13->U13_QUADRA)
											U04->U04_QUADRA := U13->U13_QUADRA
											U04->U04_MODULO := U13->U13_MODULO
											U04->U04_JAZIGO := U13->U13_JAZIGO
										endIf

									endIf

								endIf

							endif

							U04->U04_APONTA	:= cCodAptServic

							U04->(MsUnlock())

						endif

					endif

					If !Empty(cCodAptServic)

						// gravo o codigo do apontamento de servicos
						if U38->(Reclock("U38",.F.))

							// verifico se o campo do apontamento existe na tabela de transferencia de endereco
							if U38->(FieldPos("U38_APONTA")) > 0
								U38->U38_APONTA	:= cCodAptServic
							endIf

							if U38->(FieldPos("U38_STATUS")) > 0
								U38->U38_STATUS	:= "2" // status efetivado
							endIf

							U38->(MsUnlock())
						else
							U38->(DisarmTransaction())
						endIf

					EndIf

				endIf

				// gero o pedido de venda se os dados de cliente estiverem preenchidos
				if !Empty(U38->U38_CLIPV) .And. !Empty(U38->U38_LOJAPV) .And. Empty(U38->U38_PEDIDO)

					// pergunto ao usuario deseja gerar o pedido de vendas
					if lRetorno .And. MsgYesNo("Deseja gerar o pedido de venda da transferencia realizada?")

						// inclusao do pedido de vendas da transferencia de enderecos
						cPedido := U_PCPGA34A(cCtrDes,cServico,U38->U38_CODIGO)

						if !Empty(cPedido)

							MsgInfo("Pedido de Venda: " + cPedido + " gerado com sucesso!" )

						endif

					endif

				endIf

				// verifico se deu tudo certo
				if !lRetorno
					DisarmTransaction()
				else
					MsgInfo("Transferência de endereçamento realizada com sucesso!")
				endIf

			END TRANSACTION

		endif

		//restauro a filial corrente
		cFilAnt := cFilBkp

	endIf

Return(lRetorno)

/*/{Protheus.doc} RCPGA34E
Faco o estorno da transferencia
@type function
@version 1.0
@author g.sampaio
@since 03/06/2021
@param cCodTransf, character, codigo da transferencia de enderecamento
@return return_type, return_description
/*/
User Function RCPGA34D(cCodTransf)

	Local aArea			:= GetArea()
	Local aAreaU04		:= U04->(GetArea())
	Local aAreaU38		:= U38->(GetArea())
	Local aAreaUJV		:= UJV->(GetArea())
	Local aDadosU30		:= {}
	Local cQuery 		:= ""
	Local cFilBkp		:= cFilAnt
	Local lContinua		:= .T.
	Local lRetorno		:= .T.
	Local lPrevio		:= .F.
	Local lIncluiU04	:= .T.
	Local nRecU04Dest	:= 0
	Local nAnosExu		:= SuperGetMv("MV_XANOSEX",.F.,5)
	Local lAtivJazOssi  := SuperGetMV("MV_XJAZOSS",,.F.)

	// posciono na transferencia
	U38->(DbSetOrder(1))
	if U38->(MsSeek(xFilial("U38")+cCodTransf)) .And. U38->U38_STATUS == "2" // faco a validacao caso o endereco esteja efetivado

		// faco a validacao do apontamento
		lContinua := U_RCPGA34E(U38->U38_CODIGO, @aDadosU30)

		///////////////////////////////////////////////////////////////////
		///////// 	PEGO RECNO DO ENDERECAMENTO ATUAL (U04)		///////////
		///////////////////////////////////////////////////////////////////

		if lContinua

			// mudo a filial para a filial de destino
			cFilAnt := U38->U38_FILDES

			if Select("TRBDST") > 0
				TRBDST->(DBCloseArea())
			endIf

			cQuery	:= " SELECT U04.R_E_C_N_O_ RECU04 "
			cQuery	+= " FROM " + RetSQLName("U04") + " U04 "
			cQuery	+= " WHERE U04.D_E_L_E_T_ = ' ' "
			cQuery	+= " AND U04.U04_FILIAL = '" + xFilial("U04") + "' "
			cQuery	+= " AND U04.U04_CODIGO = '" + U38->U38_CTRDES + "' "
			cQuery	+= " AND U04.U04_APONTA = '" + U38->U38_APONTA + "' "

			if !Empty(U38->U38_QDDEST)

				cQuery	+= " AND U04.U04_QUADRA		= '" + U38->U38_QDDEST + "' "
				cQuery	+= " AND U04.U04_MODULO		= '" + U38->U38_MDDEST + "' "
				cQuery	+= " AND U04.U04_JAZIGO  	= '" + U38->U38_JZDEST + "' "
				cQuery	+= " AND U04.U04_GAVETA  	= '" + U38->U38_GVDEST + "' "

			elseIf !Empty(U38->U38_OSDEST)

				cQuery	+= " AND U04.U04_OSSARI		= '" + U38->U38_OSDEST + "' "
				cQuery	+= " AND U04.U04_NICHOO		= '" + U38->U38_NODEST + "' "
				cQuery  += " AND U04.U04_LACOSS		= '" + U38->U38_LACDST + "' "

			endIf

			cQuery := ChangeQuery(cQuery)

			// executo a query e crio o alias temporario
			MPSysOpenQuery(cQuery, "TRBDST")

			if TRBDST->(!Eof())
				nRecU04Dest	:= TRBDST->RECU04
			else
				lContinua := .F.
				Help(,,'Help - ESTORNOTRANSF',,"Não é permitido o estorno de Transferencia de Endereços em que o endereço de destino já foi transferido!" ,1,0)
			endIf

			if Select("TRBU04") > 0
				TRBU04->(DBCloseArea())
			endIf

			// volto a filial 
			cFilAnt := cFilBkp

		endIf

		if lContinua

			///////////////////////////////////////////////////////////////////
			///////// 	DELETO OS REGISTROS DA TRANSFERENCIA		///////////
			///////////////////////////////////////////////////////////////////

			BEGIN TRANSACTION

				// deleto o registro da UJV gerada
				UJV->(DbSetOrder(1))
				if UJV->(MsSeek(xFilial("UJV")+U38->U38_APONTA))

					if UJV->(RecLock("UJV", .F.))
						UJV->(DBDelete())
						UJV->(MsUnlock())
					else
						lContinua := .F.
						UJV->(DisarmTransaction())
					endIf

				endIf

				if lContinua

					// deleto o registro da U04 gerada
					U04->(DBGoTo(nRecU04Dest))

					if U04->(RecLock("U04", .F.))
						U04->(DBDelete())
						U04->(MsUnlock())
					else
						lContinua := .F.
						U04->(DisarmTransaction())
					endIf

				endIf

				if lContinua

					if Len(aDadosU30) > 0

						// deleto o registro da U30 gerada
						U30->(DBGoTo(aDadosU30[1]))

						if U30->(RecLock("U30",.F.))
							U30->(DBDelete())
							U30->(MsUnlock())
						else
							lContinua := .F.
							U30->(DisarmTransaction())
						endIf

					else
						lContinua := .F.
					endIf

				endIf

				if lContinua

					// posicion no apontamento original para refazer a U04
					UJV->(DBSetOrder(1))
					if UJV->(MsSeek(xFilial("UJV")+aDadosU30[7]))

						SB1->(DbSetOrder(1)) //B1_FILIAL + B1_COD
						if SB1->(MsSeek(xFilial("SB1") + UJV->UJV_SERVIC))

							U37->(DbSetOrder(2))
							if U37->(MsSeek(xFilial("U37")+ aDadosU30[2] + UJV->UJV_SERVIC ))

								//Retorno o proximo item da U04
								cNextU04 := U_NextU04(aDadosU30[2])

								//verifico se servico selecionado exige definicao de endereco
								if !Empty(SB1->B1_XREQSER)

									//valido se o endereco selecionado possui enderecamento previo d
									if SB1->B1_XREQSER == "J"

										nRegistro := U_PosPrevio(aDadosU30[2], UJV->UJV_QUADRA, UJV->UJV_MODULO, UJV->UJV_JAZIGO)

										//caso possua enderecamento previo apenas atualizo o registro da U04
										if nRegistro > 0

											U04->( DbGoTo(nRegistro) )

											if UJV->UJV_GAVETA == U04->U04_GAVETA
												cNextU04 	:= U04->U04_ITEM
												lIncluiU04	:= .F.
											endIf

											if U04->U04_PREVIO == 'S'
												dDataPrevio	:= U04->U04_DATA
												lPrevio 	:= .T.
											endIf

										endif

									endif

									// altero as informacoes do endereco
									RecLock("U04",lIncluiU04)
									U04->U04_FILIAL := xFilial("U04")
									U04->U04_CODIGO := UJV->UJV_CONTRA
									U04->U04_ITEM	:= cNextU04
									U04->U04_DTUTIL	:= UJV->UJV_DTSEPU
									U04->U04_QUEMUT	:= UJV->UJV_NOME
									U04->U04_APONTA	:= UJV->UJV_CODIGO

									// caso for uma nova inclusao
									if !lPrevio
										U04->U04_DATA	:= dDatabase
										U04->U04_PREVIO	:= "N"
									elseIf lPrevio .And. lIncluiU04
										U04->U04_DATA	:= dDataPrevio
										U04->U04_PREVIO	:= "S"
									endIf

									///////////////////////////////////////////////////////
									///////// 		ENDERECO DE GAVETA			///////////
									///////////////////////////////////////////////////////
									if SB1->B1_XREQSER == "J"

										U04->U04_TIPO	:= "J"
										U04->U04_QUADRA := UJV->UJV_QUADRA
										U04->U04_MODULO := UJV->UJV_MODULO
										U04->U04_JAZIGO := UJV->UJV_JAZIGO
										U04->U04_GAVETA := UJV->UJV_GAVETA
										U04->U04_LOCACA	:= SB1->B1_XLOCACA
										U04->U04_OCUPAG	:= SB1->B1_XOCUGAV

										//ocupa gaveta
										if SB1->B1_XOCUGAV == 'S'

											U04->U04_OCUPAG := SB1->B1_XOCUGAV
											U04->U04_PRZEXU	:= YearSum(UJV->UJV_DTSEPU,nAnosExu)

										else

											U04->U04_PRZEXU	:= UJV->UJV_DTSEPU

										endif

										///////////////////////////////////////////////////////
										///////// 		ENDERECO DE CREMACAO		///////////
										///////////////////////////////////////////////////////
									elseif SB1->B1_XREQSER == "C"

										U04->U04_TIPO	:= "C"
										U04->U04_CREMAT := UJV->UJV_CREMAT
										U04->U04_NICHOC	:= UJV->UJV_NICHOC

										///////////////////////////////////////////////////////
										///////// 		ENDERECO DE CREMACAO		///////////
										///////////////////////////////////////////////////////
									elseif SB1->B1_XREQSER == "O"

										U04->U04_TIPO	:= "O"
										U04->U04_OSSARI := UJV->UJV_OSSARI
										U04->U04_NICHOO	:= UJV->UJV_NICHOO

										// verifico se os campos de lacre existem
										if U04->(FieldPos("U04_LACOSS")) > 0 .And. UJV->(FieldPos("UJV_LACOSS")) > 0
											U04->U04_LACOSS	:= UJV->UJV_LACOSS
										endIf

										if lAtivJazOssi

											U13->(DbSetOrder(1))
											if U13->(MsSeek(xFilial("U13")+UJV->UJV_OSSARI))

												if !Empty(U13->U13_QUADRA)
													U04->U04_QUADRA := U13->U13_QUADRA
													U04->U04_MODULO := U13->U13_MODULO
													U04->U04_JAZIGO := U13->U13_JAZIGO
												endIf

											endIf

										endIf

									endif

									U04->(MsUnlock())

								EndIf

							endif

						else

							lContinua := .F.
							Help( ,, 'Help',, 'Serviço não habilito para o contrato, favor verifique o mesmo!', 1, 0 )

						endif

					else

						lContinua := .F.
						Help( ,, 'Help',, 'Serviço não encontrado, favor verifique o mesmo!', 1, 0 )

					endif

				endIf

				if lContinua

					if U38->(RecLock("U38", .F.))
						U38->U38_APONTA := ""

						If !Empty(cNextU04)
							U38->U38_ITEMEN	:= cNextU04
						EndIf

						if U38->(FieldPos("U38_STATUS")) > 0
							U38->U38_STATUS	:= "1" // status reservado
						endIf

						U38->(MsUnlock())
					else
						lContinua := .F.
						U38->(DisarmTransaction())
					endIf

				endIf

				if lContinua
					lRetorno := .T.
					MsgInfo("Estorno da transferência de endereços realizado com sucesso!")
				else
					lRetorno := .F.
					DisarmTransaction()
				endIf

			END TRANSACTION

		endIf

	endIf

	RestArea(aAreaUJV)
	RestArea(aAreaU38)
	RestArea(aAreaU04)
	RestArea(aArea)

Return(lRetorno)

/*/{Protheus.doc} RCPGA34E
Funcao para realizar a validacao da transferencia
de enderecamento.
@type function
@version 1.0
@author g.sampaio
@since 05/06/2021
@param cCodTransf, character, codigo da transferencia
@return logical, retorno
/*/
User Function RCPGA34E(cCodTransf, aDadosU30)

	Local aArea			:= GetArea()
	Local aAreaU38		:= U38->(GetArea())
	Local aAreaUJV		:= UJV->(GetArea())
	Local aAreaSB1		:= SB1->(GetArea())
	Local cCodAptOrig	:= ""
	Local lRetorno		:= .T.

	Default cCodTransf	:= ""
	Default aDadosU30	:= {}

	U38->(DbSetOrder(1))
	if U38->(MsSeek(xFilial("U38")+cCodTransf)) .And. U38->U38_STATUS == "2" // faco a validacao caso o endereco esteja efetivado

		///////////////////////////////////////////////////////////////////////////////
		///////// 	PEGO OS DADOS DO HISTORICO DE ENDERECAMENTO (U30)		///////////
		///////////////////////////////////////////////////////////////////////////////
		if Select("TRBU30") > 0
			TRBU30->(DBCloseArea())
		endIf

		cQuery := "	SELECT U30.R_E_C_N_O_ RECU30, U30.* "
		cQuery += " FROM " + RetSQLName("U30") + " U30 "
		cQuery += "	WHERE U30.D_E_L_E_T_ = ' ' "
		cQuery += " AND U30.U30_FILIAL = '" + xFilial("U30") + "' "
		cQuery += " AND U30.U30_TRANSF = 'S' "
		cQuery += " AND U30.U30_DTHIST = '" + Dtos(U38->U38_DATA) + "' "
		cQuery += "	AND U30.U30_CODIGO = '" + U38->U38_CTRORI + "' "
		cQuery += "	AND U30.U30_QUADRA = '" + U38->U38_QUADRA + "' "
		cQuery += "	AND U30.U30_MODULO = '" + U38->U38_MODULO + "' "
		cQuery += "	AND U30.U30_JAZIGO = '" + U38->U38_JAZIGO + "' "
		cQuery += "	AND U30.U30_GAVETA = '" + U38->U38_GAVETA + "' "
		cQuery += " AND U30.U30_ITGAVE = '" + U38->U38_ITEMEN + "' "

		if U30->(FieldPos("U30_CODORI")) > 0
			cQuery += " AND U30.U30_CODORI = '" + U38->U38_CODIGO + "' "
		endIf

		cQuery := ChangeQuery(cQuery)

		// executo a query e crio o alias temporario
		MPSysOpenQuery( cQuery, 'TRBU30' )

		if TRBU30->(!Eof())
			aDadosU30 := {}

			AAdd( aDadosU30, TRBU30->RECU30 ) 		// [1] Recno U30
			AAdd( aDadosU30, TRBU30->U30_CODIGO )	// [2] Contrato
			AAdd( aDadosU30, TRBU30->U30_ITGAVE )	// [3] Item Gaveta
			AAdd( aDadosU30, TRBU30->U30_DTUTIL )	// [4] Data da Utilizacao original
			AAdd( aDadosU30, TRBU30->U30_QUEMUT )	// [5] Nome do Falecido
			AAdd( aDadosU30, TRBU30->U30_DTHIST )	// [6] Data da geracao do historico
			AAdd( aDadosU30, TRBU30->U30_APONTA )	// [7] Codigo do apontamento

		endIf

		if Select("TRBU30") > 0
			TRBU30->(DBCloseArea())
		endIf

		if Len(aDadosU30) > 0
			cCodAptOrig := aDadosU30[7]
		endIf

		UJV->(DbSetOrder(1))
		if UJV->(MsSeek(xFilial("UJV")+cCodAptOrig))

			///////////////////////////////////////////////////////////////////
			/////////  VALIDO SE A TRANSFERENCIA ESTÁ EFETIVADA		///////////
			///////////////////////////////////////////////////////////////////

			if (U38->U38_STATUS == "1" .Or. Empty(U38->U38_STATUS)) .And. !FWIsInCallStack("U_PCPGA034")
				lRetorno	:= .F.
				Help(,,'Help - ESTORNOTRANSF',,"Não é permitido o estorno de Transferencia de Endereços com Status diferente de 'Efetivado'!" ,1,0)
			endIf

			///////////////////////////////////////////////////////////////////////////
			/////////  VALIDO SE A TRANSFERENCIA TEM PEDIDO DE VENDAS		///////////
			///////////////////////////////////////////////////////////////////////////

			if lRetorno .And. !Empty(U38->U38_PEDIDO) .And. FWIsInCallStack("U_PCPGA034")
				lRetorno	:= .F.
				Help(,,'Help - ESTORNOTRANSF',,"Não é permitido o exclusão de Transferencia de Endereços com Pedido de Vendas gerado!" ,1,0)
			endIf

			///////////////////////////////////////////////////////////////////////////
			///////// 		VALIDO SE O ENDERECO ORIGINAL ESTA OCUPADO		///////////
			///////////////////////////////////////////////////////////////////////////

			if lRetorno

				// pego os dados do servico de origem
				SB1->(DbSetOrder(1))
				if SB1->(MsSeek(xFilial("SB1")+UJV->UJV_SERVIC))
					cTipoServico 	:= SB1->B1_XREQSER	// tipo do servico de origem
					cOcupaGav		:= SB1->B1_XOCUGAV	// servico de origem preenche gaveta
				endIf

				if Select("TRBU04") > 0
					TRBU04->(DBCloseArea())
				endIf

				cQuery	:= " SELECT U04.R_E_C_N_O_ RECU04 "
				cQuery	+= " FROM " + RetSQLName("U04") + " U04 "
				cQuery	+= " WHERE U04.D_E_L_E_T_ = ' ' "
				cQuery	+= " AND U04.U04_FILIAL		= '" + xFilial("U04") + "' "
				cQuery	+= " AND U04.U04_CODIGO		= '" + U38->U38_CTRORI + "' "

				if !Empty(U38->U38_QUADRA)
					cQuery	+= " AND U04.U04_QUADRA		= '" + U38->U38_QUADRA + "' "
					cQuery	+= " AND U04.U04_MODULO		= '" + U38->U38_MODULO + "' "
					cQuery	+= " AND U04.U04_JAZIGO  	= '" + U38->U38_JAZIGO + "' "
					cQuery	+= " AND U04.U04_GAVETA  	= '" + U38->U38_GAVETA + "' "
				elseIf !Empty(U38->U38_OSSARI)
					cQuery	+= " AND U04.U04_OSSARI		= '" + U38->U38_OSSARI + "' "
					cQuery	+= " AND U04.U04_NICHOO		= '" + U38->U38_NICHOO + "' "
					cQuery  += " AND U04.U04_LACOSS		= '" + U38->U38_LACORI + "' "
				endIf

				cQuery := ChangeQuery(cQuery)

				// executo a query e crio o alias temporario
				MPSysOpenQuery( cQuery, 'TRBU04' )

				while TRBU04->(!Eof())

					if lRetorno

						U04->(DBGoTo(TRBU04->RECU04))

						if U04->U04_CODIGO <> U38->U38_CTRORI .And. U04->U04_CODIGO <> U38->U38_CTRDES
							lRetorno	:= .F.
							Help(,,'Help - ESTORNOTRANSF',,"Não é permitido o estorno de Transferencia de Endereços, onde o endereço esteja vinculado'";
								+ " a outro contrato diferente do contrato de origem ou destino!" ,1,0)
						elseIf cTipoServico == "J" .And. cOcupaGav == "S" .And. U04->U04_OCUPAG == "S"
							lRetorno	:= .F.
							Help(,,'Help - ESTORNOTRANSF',,"Não é permitido o estorno de Transferencia de Endereços, onde o endereço esteja ocupado!'",1,0)
						endIf

					endIf

					TRBU04->(DbSkip())
				endDo

				if Select("TRBU04") > 0
					TRBU04->(DBCloseArea())
				endIf

			endIf

		endIf

	endIf

	RestArea(aAreaSB1)
	RestArea(aAreaUJV)
	RestArea(aAreaU38)
	RestArea(aArea)

Return(lRetorno)

/*/{Protheus.doc} MaxItemU30
Funcao para consultar Proximo item
que sera gerado no historico da gaveta
@author Raphael Martins 
@since 17/05/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function MaxItemU30(cContrato)

	Local aArea		:= GetArea()
	Local aAreaU04	:= U04->(GetArea())
	Local cQry		:= ""
	Local cProxItem	:= ""

	cQry := " SELECT
	cQry += " ISNULL(MAX(U30_ITEM),'00') MAX_ITEM "
	cQry += " FROM "
	cQry += + RetSQLName("U30") + " HIST "
	cQry += " WHERE "
	cQry += " HIST.D_E_L_E_T_ = ' ' "
	cQry += " AND U30_FILIAL = '"+xFilial("U30")+"' "
	cQry += " AND U30_CODIGO = '" + cContrato + "' "

	// verifico se não existe este alias criado
	If Select("QRY") > 0
		QRY->(DbCloseArea())
	EndIf

	// função que converte a query genérica para o protheus
	cQry := ChangeQuery(cQry)

	// executo a query e crio o alias temporario
	MPSysOpenQuery( cQry, 'QRY' )

	//proximo item da tabela de historico de enderecamento
	cProxItem := StrZero(Val(QRY->MAX_ITEM) + 1,TamSX3("U30_ITEM")[1])

	RestArea(aArea)
	RestArea(aAreaU04)

Return(cProxItem)

/*/{Protheus.doc} RefazEndPrevio
Funcao para refazer o enderecamento previo
@type function
@version 1.0
@author g.sampaio
@since 02/03/2021
@param nRecnoU04, numeric, recno do endereco
/*/
Static Function RefazEndPrevio(nRecnoU04)

	Local aArea 			:= GetArea()
	Local aAreaU04			:= U04->(GetArea())
	Local cQuery 			:= ""
	Local cContratoAtual 	:= ""
	Local cQuadraAtual 		:= ""
	Local cMdouloAtual		:= ""
	Local cJazigoAtual		:= ""
	Local cGavetaAtual		:= ""
	Local dDataPrevio		:= stod("")

	// posiciono no registro da U04
	U04->(DBGoTo(nRecnoU04))

	// dados atuais do endereco
	cContratoAtual 	:= U04->U04_CODIGO
	cQuadraAtual 	:= U04->U04_QUADRA
	cMdouloAtual	:= U04->U04_MODULO
	cJazigoAtual	:= U04->U04_JAZIGO
	cGavetaAtual	:= U04->U04_GAVETA
	dDataPrevio		:= U04->U04_DATA

	// deleto o registro da U04
	If U04->(RecLock("U04",.F.))
		U04->(DbDelete())
		U04->(MsUnlock())
	EndIf

	If Select("TRBEND") > 0
		TRBEND->(DbCloseArea())
	endIf

	cQuery := " SELECT U04.R_E_C_N_O_ RECU04 FROM "
	cQuery += RetSQLName("U04") + " U04 "
	cQuery += " WHERE U04.D_E_L_E_T_ = ' ' "
	cQuery += " AND U04.U04_FILIAL = '" + xFilial("U04") + "' "
	cQuery += " AND U04.U04_PREVIO = 'S' "
	cQuery += " AND U04.U04_CODIGO = '" + cContratoAtual + "' "
	cQuery += " AND U04.U04_QUADRA = '" + cQuadraAtual + "' "
	cQuery += " AND U04.U04_MODULO = '" + cMdouloAtual + "' "
	cQuery += " AND U04.U04_JAZIGO = '" + cJazigoAtual + "' "
	cQuery += " AND U04.U04_GAVETA <> '" + cGavetaAtual + "' "

	// função que converte a query genérica para o protheus
	cQuery := ChangeQuery(cQuery)

	// executo a query e crio o alias temporario
	MPSysOpenQuery( cQuery, 'TRBEND' )

	// se não existir outra gaveta para contrato
	if TRBEND->(Eof())

		// crio o registro de enderecamento previo
		RecLock("U04",.T.)
		U04->U04_FILIAL := xFilial("U04")
		U04->U04_CODIGO	:= cContratoAtual
		U04->U04_ITEM	:= U_NextU04(cContratoAtual)
		U04->U04_TIPO	:= "J" //Jazigo
		U04->U04_QUADRA	:= cQuadraAtual
		U04->U04_MODULO	:= cMdouloAtual
		U04->U04_JAZIGO	:= cJazigoAtual
		U04->U04_GAVETA	:= StrZero(1,2)
		U04->U04_CREMAT	:= ""
		U04->U04_NICHOC	:= ""
		U04->U04_OSSARI	:= ""
		U04->U04_NICHOO	:= ""
		U04->U04_DATA	:= dDataPrevio
		U04->U04_DTUTIL	:= Stod("")
		U04->U04_QUEMUT	:= ""
		U04->U04_PRZEXU	:= Stod("")
		U04->U04_PREVIO	:= "S"
		U04->U04_OCUPAG := "S"
		U04->U04_LOCACA	:= "N"

		U04->(MsUnlock())

	endIf

	If Select("TRBEND") > 0
		TRBEND->(DbCloseArea())
	endIf

	RestArea(aAreaU04)
	RestArea(aArea)

Return(Nil)
