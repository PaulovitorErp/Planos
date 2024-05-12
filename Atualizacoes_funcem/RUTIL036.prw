#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

Static lSM0Open := .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} RUTIL036
'Cadastro de Agendamento de JOB'

@type Function
@author Pablo Nunes
@since 11/07/2022
@version 1.0
@return nil, retorna nulo
/*/
//-------------------------------------------------------------------
User Function RUTIL036()

	Local oBrowse := FWMBrowse():New()

	oBrowse:SetAlias('UZG')
	oBrowse:SetMenuDef('RUTIL036')
	oBrowse:SetDescription('Cadastro de Agendamento de JOB')
	oBrowse:Activate()
	oBrowse:Destroy()
	GTPDestroy(oBrowse)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função responsavel pela definição do menu
@type Static Function
@author Pablo Nunes
@since 11/07/2022
@version 1.0
@return aRotina, retorna as opções do menu
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE "Visualizar" ACTION 'VIEWDEF.RUTIL036' OPERATION 02	ACCESS 0 // "Visualizar"
	ADD OPTION aRotina TITLE "Incluir"    ACTION 'VIEWDEF.RUTIL036' OPERATION 03	ACCESS 0 // "Incluir"
	ADD OPTION aRotina TITLE "Alterar"    ACTION 'VIEWDEF.RUTIL036' OPERATION 04	ACCESS 0 // "Alterar"
	ADD OPTION aRotina TITLE "Excluir"    ACTION 'VIEWDEF.RUTIL036' OPERATION 05	ACCESS 0 // "Excluir"
	ADD OPTION aRotina TITLE "Imprimir"   ACTION 'VIEWDEF.RUTIL036' OPERATION 08	ACCESS 0 // "Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função responsavel pela definição do modelo
@type Static Function
@author Pablo Nunes
@since 11/07/2022
@version 1.0
@return oModel, retorna o Objeto do Menu
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oModel	:= nil
	Local oStrUZG	:= FWFormStruct(1,'UZG')

	oModel := MPFormModel():New('PUTIL036', /*bPreValidacao*/,{|oModel|UTIL36AllOk(oModel)}, /*bCommit*/, /*bCancel*/ )
	oModel:AddFields('UZGMASTER',/*cOwner*/,oStrUZG)
	oModel:SetDescription('Cadastro de Agendamento de JOB')
	oModel:GetModel('UZGMASTER'):SetDescription('Cadastro de Agendamento de JOB')
	oModel:SetPrimaryKey({'UZG_FILIAL','UZG_CODIGO'})

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função responsavel pela definição da view
@type Static Function
@author Pablo Nunes
@since 11/07/2022
@version 1.0
@return oView, retorna o Objeto da View
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oView		:= FWFormView():New()
	Local oModel	:= FwLoadModel('RUTIL036')
	Local oStrUZG	:= FWFormStruct(2, 'UZG')

	oStrUZG:SetProperty('UZG_EMPFIL',MVC_VIEW_LOOKUP,'UZGEMP') //Consulta F3

	oView:SetModel(oModel)
	oView:AddField('VIEW_UZG' ,oStrUZG,'UZGMASTER')
	oView:CreateHorizontalBox('TELA', 100)
	oView:SetOwnerView('VIEW_UZG','TELA')
	oView:SetDescription('Cadastro de Agendamento de JOB')

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} UTIL36AllOk(oModel)
description
@author  Pablo Nunes
@since   11/07/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function UTIL36AllOk(oModel)

	Local lRet		:= .T.
	Local oMdlUZG	:= oModel:GetModel('UZGMASTER')

	If !ExistChav('UZG',oMdlUZG:GetValue("UZG_CODIGO"))
		lRet := .F.
		oModel:SetErrorMessage(oMdlUZG:GetId(),"",oMdlUZG:GetId(),"",'UTIL36AllOk',"Código já existente na base","Código já existente na base")
	Endif

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} RUTIL36A
Consulta Padrão: UZGEMP -> UZG_EMPFIL
@author  Pablo Nunes
@since   11/07/2022
@version 1.0
/*/
//-------------------------------------------------------------------
User Function RUTIL36A()

	Local aRet 		:= {}
	Local aTmp 		:= {}
	Local aMarcados := {}
	Local cReadVar 	:= Alltrim(ReadVar()) //M->UZG_EMPFIL
	Local cRet	 	:= &(cReadVar) //Ex.: 99/01;99/02; ...
	Local nX 		:= 0

	aTmp := StrtoKarr2(cRet,";")
	For nX:=1 to Len(aTmp)
		aTmp2 := StrtoKarr2(aTmp[nX],"/")
		If Len(aTmp2) == 2
			aadd(aMarcados,{aTmp2[01],aTmp2[02]})
		EndIf
	Next nX

	aRet := ESCEMPRESA(aMarcados)

	If Len(aRet) > 0
		cRet := ""
		For nX:=1 to Len(aRet)
			cRet += AllTrim(aRet[nX][01])+"/"+AllTrim(aRet[nX][02])+";"
		Next nX
		cRet := PadR(AllTrim(cRet),TamSx3(StrTran(cReadVar,"M->",""))[1])
	EndIf

	If Empty(cRet)
		cRet := Space(TamSx3(StrTran(cReadVar,"M->",""))[1])
	EndIf

	&(cReadVar) := cRet

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ESCEMPRESA
Funcao Generica para escolha de Empresa, montado pelo SM0.
Retorna vetor contendo as selecoes feitas.
Se nao For marcada nenhuma o vetor volta vazio. 
@author  Pablo Nunes
@since   11/07/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ESCEMPRESA(aMarcadas)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametro  nTipo                           ³
//³ 1  - Monta com Todas Empresas/Filiais      ³
//³ 2  - Monta so com Empresas                 ³
//³ 3  - Monta so com Filiais de uma Empresa   ³
//³                                            ³
//³ Parametro  aMarcadas                       ³
//³ Vetor com Empresas/Filiais pre marcadas    ³
//³                                            ³
//³ Parametro  cEmpSel                         ³
//³ Empresa que sera usada para montar selecao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local   aSalvAmb := GetArea()
	Local   aSalvSM0 := {}
	Local   aRet     := {}
	Local   aVetor   := {}
	Local   oDlg     := NIL
	Local   oChkMar  := NIL
	Local   oLbx     := NIL
	Local   oMascEmp := NIL
	Local   oButMarc := NIL
	Local   oButDMar := NIL
	Local   oButInv  := NIL
	Local   oSay     := NIL
	Local   oOk      := LoadBitmap( GetResources(), "LBOK" )
	Local   oNo      := LoadBitmap( GetResources(), "LBNO" )
	Local   lChk     := .F.
	Local   lTeveMarc:= .F.
	Local   cVar     := ""
	Local   cMascEmp := "??"
	Local   cMascFil := "??"

	Default aMarcadas  := {}

	If !MyOpenSm0(.F.)
		Return aRet
	EndIf

	dbSelectArea( "SM0" )
	aSalvSM0 := SM0->( GetArea() )
	dbSetOrder( 1 )
	dbGoTop()

	While !SM0->( EOF() )
		If aScan( aVetor, {|x| x[2] == SM0->M0_CODIGO .and. x[3] == SM0->M0_CODFIL} ) == 0
			aAdd(  aVetor, { aScan( aMarcadas, {|x| AllTrim(x[1]) == AllTrim(SM0->M0_CODIGO) .and. AllTrim(x[2]) == AllTrim(SM0->M0_CODFIL)} ) > 0, AllTrim(SM0->M0_CODIGO), AllTrim(SM0->M0_CODFIL), SM0->M0_NOME, SM0->M0_FILIAL } )
		EndIf
		dbSkip()
	End

	RestArea( aSalvSM0 )

	Define MSDialog  oDlg Title "" From 0, 0 To 270, 396 Pixel

	oDlg:cToolTip := "Tela para Múltiplas Seleções de Empresas/Filiais"

	oDlg:cTitle   := "Selecione a(s) Filial(ais) para JOB"

	@ 10, 10 Listbox  oLbx Var  cVar Fields Header " ", "Empresa", "Filial", "Grupo", "Nome" Size 178, 095 Of oDlg Pixel //
	oLbx:SetArray(  aVetor )
	oLbx:bLine := {|| {IIf( aVetor[oLbx:nAt,1], oOk, oNo ), ;
		aVetor[oLbx:nAt,2], ;
		aVetor[oLbx:nAt,3], ;
		aVetor[oLbx:nAt,4], ;
		aVetor[oLbx:nAt,5]}}
	oLbx:BlDblClick := { || aVetor[oLbx:nAt, 1] := !aVetor[oLbx:nAt, 1], VerTodos( aVetor, @lChk, oChkMar ), oChkMar:Refresh(), oLbx:Refresh()}
	oLbx:cToolTip   :=  oDlg:cTitle
	oLbx:lHScroll   := .F. // NoScroll

	@ 112, 10 CheckBox oChkMar Var  lChk Prompt "Todos"   Message  Size 40, 007 Pixel Of oDlg;
		on Click MarcaTodos( lChk, @aVetor, oLbx )

	@ 123, 10 Button oButInv Prompt "&Inverter"  Size 32, 12 Pixel Action ( InvSelecao( @aVetor, oLbx, @lChk, oChkMar ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
		Message "Inverter Seleção" Of oDlg

// Marca/Desmarca por mascara
	@ 113, 51 Say  oSay Prompt "Empresa" Size  40, 08 Of oDlg Pixel
	@ 112, 80 MSGet  oMascEmp Var  cMascEmp Size  05, 05 Pixel Picture "@!"  Valid (  cMascEmp := StrTran( cMascEmp, " ", "?" ), cMascFil := StrTran( cMascFil, " ", "?" ), oMascEmp:Refresh(), .T. ) ;
		Message "Máscara Empresa ( ?? )"  Of oDlg
	@ 123, 50 Button oButMarc Prompt "&Marcar"    Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .T. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
		Message "Marcar usando máscara ( ?? )"    Of oDlg
	@ 123, 90 Button oButDMar Prompt "&Desmarcar" Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .F. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
		Message "Desmarcar usando máscara ( ?? )" Of oDlg

	Define SButton From 111, 125 Type 1 Action ( RetSelecao( @aRet, aVetor ), oDlg:End() ) OnStop "Confirma a Seleção"  Enable Of oDlg
	Define SButton From 111, 158 Type 2 Action ( IIf( lTeveMarc, aRet :=  aMarcadas, .T. ), oDlg:End() ) OnStop "Abandona a Seleção" Enable Of oDlg
	Activate MSDialog  oDlg Center

	RestArea( aSalvAmb )
	dbSelectArea( "SM0" )
	//dbCloseArea()

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MarcaTodos
Funcao Auxiliar para marcar/desmarcar todos os itens do ListBox ativo
@author  Pablo Nunes
@since   11/07/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MarcaTodos( lMarca, aVetor, oLbx )

	Local  nI := 0

	For nI := 1 To Len( aVetor )
		aVetor[nI][1] := lMarca
	Next nI
	oLbx:Refresh()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} InvSelecao
Funcao Auxiliar para inverter selecao do ListBox Ativo
@author  Pablo Nunes
@since   11/07/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function InvSelecao( aVetor, oLbx )

	Local  nI := 0

	For nI := 1 To Len( aVetor )
		aVetor[nI][1] := !aVetor[nI][1]
	Next nI

	oLbx:Refresh()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} RetSelecao
Funcao Auxiliar que monta o retorno com as selecoes
@author  Pablo Nunes
@since   11/07/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetSelecao( aRet, aVetor )

	Local  nI    := 0

	aRet := {}
	For nI := 1 To Len( aVetor )
		If aVetor[nI][1]
			aAdd( aRet, { aVetor[nI][2] , aVetor[nI][3], aVetor[nI][2] +  aVetor[nI][3] } )
		EndIf
	Next nI

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MarcaMas
Funcao para marcar/desmarcar usando mascaras
@author  Pablo Nunes
@since   11/07/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MarcaMas( oLbx, aVetor, cMascEmp, lMarDes )

	Local cPos1 := SubStr( cMascEmp, 1, 1 )
	Local cPos2 := SubStr( cMascEmp, 2, 1 )
	Local nPos  := oLbx:nAt
	Local nZ    := 0

	For nZ := 1 To Len( aVetor )
		If cPos1 == "?" .or. SubStr( aVetor[nZ][2], 1, 1 ) == cPos1
			If cPos2 == "?" .or. SubStr( aVetor[nZ][2], 2, 1 ) == cPos2
				aVetor[nZ][1] :=  lMarDes
			EndIf
		EndIf
	Next

	oLbx:nAt := nPos
	oLbx:Refresh()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} VerTodos
Funcao auxiliar para verificar se estao todos marcardos ou não
@author  Pablo Nunes
@since   11/07/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function VerTodos( aVetor, lChk, oChkMar )

	Local lTTrue := .T.
	Local nI     := 0

	For nI := 1 To Len( aVetor )
		lTTrue := IIf( !aVetor[nI][1], .F., lTTrue )
	Next nI

	lChk := IIf( lTTrue, .T., .F. )
	oChkMar:Refresh()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MyOpenSM0
Funcao de processamento abertura do SM0 modo exclusivo 
@author  Pablo Nunes
@since   11/07/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MyOpenSM0(lShared)

	Local lOpen := .F.
	Local nLoop := 0

	OpenSM0()

	If !lSM0Open
		dbSelectArea( "SM0" )
		SM0->(dbGoTop())
		RpcSetType( 3 )
		RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL ,,, "FRT") //Uso essa função para setar o cEmpAnt/cFilAnt
		lSM0Open := .T.
	EndIf

	For nLoop := 1 To 20
		dbSelectArea( "SM0" )
		If !Empty( Select( "SM0" ) ) .And. SoftLock("SM0")
			MsUnLockAll()
			lOpen := .T.
			Exit
		EndIf
		Sleep( 500 )
	Next nLoop

	If !lOpen
		MsgStop( "Não foi possível a abertura da tabela " + ;
			IIf( lShared, "de empresas (SM0).", "de empresas (SM0) de forma exclusiva." ), "ATENÇÃO" )
	EndIf

Return lOpen



