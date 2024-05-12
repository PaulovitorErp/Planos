#INCLUDE "PROTHEUS.CH"

#DEFINE SIMPLES Char( 39 )
#DEFINE DUPLAS  Char( 34 )

#DEFINE CSSBOTAO	"QPushButton { color: #024670; "+;
"    border-image: url(rpo:fwstd_btn_nml.png) 3 3 3 3 stretch; "+;
"    border-top-width: 3px; "+;
"    border-left-width: 3px; "+;
"    border-right-width: 3px; "+;
"    border-bottom-width: 3px }"+;
"QPushButton:pressed {	color: #FFFFFF; "+;
"    border-image: url(rpo:fwstd_btn_prd.png) 3 3 3 3 stretch; "+;
"    border-top-width: 3px; "+;
"    border-left-width: 3px; "+;
"    border-right-width: 3px; "+;
"    border-bottom-width: 3px }"

//--------------------------------------------------------------------
/*/{Protheus.doc} UPDVIR4
Função de update de dicionários para compatibilização

@author TOTVS Protheus
@since  26/03/2020
@obs    Gerado por EXPORDIC - V.6.3.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
User Function UPDVIR4( cEmpAmb, cFilAmb )

Local   aSay      := {}
Local   aButton   := {}
Local   aMarcadas := {}
Local   cTitulo   := "ATUALIZAÇÃO DE DICIONÁRIOS E TABELAS"
Local   cDesc1    := "Esta rotina tem como função fazer  a atualização  dos dicionários do Sistema ( SX?/SIX )"
Local   cDesc2    := "Este processo deve ser executado em modo EXCLUSIVO, ou seja não podem haver outros"
Local   cDesc3    := "usuários  ou  jobs utilizando  o sistema.  É EXTREMAMENTE recomendavél  que  se  faça um"
Local   cDesc4    := "BACKUP  dos DICIONÁRIOS  e da  BASE DE DADOS antes desta atualização, para que caso "
Local   cDesc5    := "ocorram eventuais falhas, esse backup possa ser restaurado."
Local   cDesc6    := ""
Local   cDesc7    := ""
Local   cMsg      := ""
Local   lOk       := .F.
Local   lAuto     := ( cEmpAmb <> NIL .or. cFilAmb <> NIL )

Private oMainWnd  := NIL
Private oProcess  := NIL

#IFDEF TOP
    TCInternal( 5, "*OFF" ) // Desliga Refresh no Lock do Top
#ENDIF

__cInterNet := NIL
__lPYME     := .F.

Set Dele On

// Mensagens de Tela Inicial
aAdd( aSay, cDesc1 )
aAdd( aSay, cDesc2 )
aAdd( aSay, cDesc3 )
aAdd( aSay, cDesc4 )
aAdd( aSay, cDesc5 )
//aAdd( aSay, cDesc6 )
//aAdd( aSay, cDesc7 )

// Botoes Tela Inicial
aAdd(  aButton, {  1, .T., { || lOk := .T., FechaBatch() } } )
aAdd(  aButton, {  2, .T., { || lOk := .F., FechaBatch() } } )

If lAuto
	lOk := .T.
Else
	FormBatch(  cTitulo,  aSay,  aButton )
EndIf

If lOk

	If lAuto
		aMarcadas :={{ cEmpAmb, cFilAmb, "" }}
	Else
		aMarcadas := EscEmpresa()
	EndIf

	If !Empty( aMarcadas )
		If lAuto .OR. MsgNoYes( "Confirma a atualização dos dicionários ?", cTitulo )
			oProcess := MsNewProcess():New( { | lEnd | lOk := FSTProc( @lEnd, aMarcadas, lAuto ) }, "Atualizando", "Aguarde, atualizando ...", .F. )
			oProcess:Activate()

			If lAuto
				If lOk
					MsgStop( "Atualização Realizada.", "UPDVIR4" )
				Else
					MsgStop( "Atualização não Realizada.", "UPDVIR4" )
				EndIf
				dbCloseAll()
			Else
				If lOk
					Final( "Atualização Realizada." )
				Else
					Final( "Atualização não Realizada." )
				EndIf
			EndIf

		Else
			Final( "Atualização não Realizada." )

		EndIf

	Else
		Final( "Atualização não Realizada." )

	EndIf

EndIf

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSTProc
Função de processamento da gravação dos arquivos

@author TOTVS Protheus
@since  26/03/2020
@obs    Gerado por EXPORDIC - V.6.3.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSTProc( lEnd, aMarcadas, lAuto )
Local   aInfo     := {}
Local   aRecnoSM0 := {}
Local   cAux      := ""
Local   cFile     := ""
Local   cFileLog  := ""
Local   cMask     := "Arquivos Texto" + "(*.TXT)|*.txt|"
Local   cTCBuild  := "TCGetBuild"
Local   cTexto    := ""
Local   cTopBuild := ""
Local   lOpen     := .F.
Local   lRet      := .T.
Local   nI        := 0
Local   nPos      := 0
Local   nRecno    := 0
Local   nX        := 0
Local   oDlg      := NIL
Local   oFont     := NIL
Local   oMemo     := NIL

Private aArqUpd   := {}

If ( lOpen := MyOpenSm0(.T.) )

	dbSelectArea( "SM0" )
	dbGoTop()

	While !SM0->( EOF() )
		// Só adiciona no aRecnoSM0 se a empresa for diferente
		If aScan( aRecnoSM0, { |x| x[2] == SM0->M0_CODIGO } ) == 0 ;
		   .AND. aScan( aMarcadas, { |x| x[1] == SM0->M0_CODIGO } ) > 0
			aAdd( aRecnoSM0, { Recno(), SM0->M0_CODIGO } )
		EndIf
		SM0->( dbSkip() )
	End

	SM0->( dbCloseArea() )

	If lOpen

		For nI := 1 To Len( aRecnoSM0 )

			If !( lOpen := MyOpenSm0(.F.) )
				MsgStop( "Atualização da empresa " + aRecnoSM0[nI][2] + " não efetuada." )
				Exit
			EndIf

			SM0->( dbGoTo( aRecnoSM0[nI][1] ) )

			RpcSetType( 3 )
			RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL )

			lMsFinalAuto := .F.
			lMsHelpAuto  := .F.

			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( "LOG DA ATUALIZAÇÃO DOS DICIONÁRIOS" )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " " )
			AutoGrLog( " Dados Ambiente" )
			AutoGrLog( " --------------------" )
			AutoGrLog( " Empresa / Filial...: " + cEmpAnt + "/" + cFilAnt )
			AutoGrLog( " Nome Empresa.......: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOMECOM", cEmpAnt + cFilAnt, 1, "" ) ) ) )
			AutoGrLog( " Nome Filial........: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) )
			AutoGrLog( " DataBase...........: " + DtoC( dDataBase ) )
			AutoGrLog( " Data / Hora Ínicio.: " + DtoC( Date() )  + " / " + Time() )
			AutoGrLog( " Environment........: " + GetEnvServer()  )
			AutoGrLog( " StartPath..........: " + GetSrvProfString( "StartPath", "" ) )
			AutoGrLog( " RootPath...........: " + GetSrvProfString( "RootPath" , "" ) )
			AutoGrLog( " Versão.............: " + GetVersao(.T.) )
			AutoGrLog( " Usuário TOTVS .....: " + __cUserId + " " +  cUserName )
			AutoGrLog( " Computer Name......: " + GetComputerName() )

			aInfo   := GetUserInfo()
			If ( nPos    := aScan( aInfo,{ |x,y| x[3] == ThreadId() } ) ) > 0
				AutoGrLog( " " )
				AutoGrLog( " Dados Thread" )
				AutoGrLog( " --------------------" )
				AutoGrLog( " Usuário da Rede....: " + aInfo[nPos][1] )
				AutoGrLog( " Estação............: " + aInfo[nPos][2] )
				AutoGrLog( " Programa Inicial...: " + aInfo[nPos][5] )
				AutoGrLog( " Environment........: " + aInfo[nPos][6] )
				AutoGrLog( " Conexão............: " + AllTrim( StrTran( StrTran( aInfo[nPos][7], Chr( 13 ), "" ), Chr( 10 ), "" ) ) )
			EndIf
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " " )

			If !lAuto
				AutoGrLog( Replicate( "-", 128 ) )
				AutoGrLog( "Empresa : " + SM0->M0_CODIGO + "/" + SM0->M0_NOME + CRLF )
			EndIf

			oProcess:SetRegua1( 8 )

			//------------------------------------
			// Atualiza o dicionário SXA
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de pastas" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSXA()

			//------------------------------------
			// Atualiza o dicionário SXB
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de consultas padrão" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FSAtuSXB()

			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " Data / Hora Final.: " + DtoC( Date() ) + " / " + Time() )
			AutoGrLog( Replicate( "-", 128 ) )

			RpcClearEnv()

		Next nI

		If !lAuto

			cTexto := LeLog()

			Define Font oFont Name "Mono AS" Size 5, 12

			Define MsDialog oDlg Title "Atualização concluida." From 3, 0 to 340, 417 Pixel

			@ 5, 5 Get oMemo Var cTexto Memo Size 200, 145 Of oDlg Pixel
			oMemo:bRClicked := { || AllwaysTrue() }
			oMemo:oFont     := oFont

			Define SButton From 153, 175 Type  1 Action oDlg:End() Enable Of oDlg Pixel // Apaga
			Define SButton From 153, 145 Type 13 Action ( cFile := cGetFile( cMask, "" ), If( cFile == "", .T., ;
			MemoWrite( cFile, cTexto ) ) ) Enable Of oDlg Pixel

			Activate MsDialog oDlg Center

		EndIf

	EndIf

Else

	lRet := .F.

EndIf

Return lRet


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSXA
Função de processamento da gravação do SXA - Pastas

@author TOTVS Protheus
@since  26/03/2020
@obs    Gerado por EXPORDIC - V.6.3.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSXA()
Local aEstrut   := {}
Local aSXA      := {}
Local cAlias    := ""
Local nI        := 0
Local nJ        := 0
Local nPosAgr   := 0
Local lAlterou  := .F.

AutoGrLog( "Ínicio da Atualização" + " SXA" + CRLF )

aEstrut := { "XA_ALIAS"  , "XA_ORDEM"  , "XA_DESCRIC", "XA_DESCSPA", "XA_DESCENG", "XA_AGRUP"  , "XA_TIPO"   , ;
             "XA_PROPRI" }


//
// Tabela SB1
//
aAdd( aSXA, { ;
	'SB1'																	, ; //XA_ALIAS
	'9'																		, ; //XA_ORDEM
	'Cemiterio - Serviços'													, ; //XA_DESCRIC
	'Cemiterio - Serviços'													, ; //XA_DESCSPA
	'Cemiterio - Serviços'													, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'SB1'																	, ; //XA_ALIAS
	'A'																		, ; //XA_ORDEM
	'Funeraria - Serviços'													, ; //XA_DESCRIC
	'Funeraria - Serviços'													, ; //XA_DESCSPA
	'Funeraria - Serviços'													, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'SB1'																	, ; //XA_ALIAS
	'B'																		, ; //XA_ORDEM
	'Cemiterio e Funeraria'													, ; //XA_DESCRIC
	'Cemiterio e Funeraria'													, ; //XA_DESCSPA
	'Cemiterio e Funeraria'													, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

//
// Tabela U00
//
aAdd( aSXA, { ;
	'U00'																	, ; //XA_ALIAS
	'1'																		, ; //XA_ORDEM
	'Dados'																	, ; //XA_DESCRIC
	'Dados'																	, ; //XA_DESCSPA
	'Dados'																	, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U00'																	, ; //XA_ALIAS
	'1'																		, ; //XA_ORDEM
	'Dados do Plano'														, ; //XA_DESCRIC
	'Dados do Plano'														, ; //XA_DESCSPA
	'Dados do Plano'														, ; //XA_DESCENG
	'A02'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U00'																	, ; //XA_ALIAS
	'2'																		, ; //XA_ORDEM
	'Cessionario'															, ; //XA_DESCRIC
	'Cessionario'															, ; //XA_DESCSPA
	'Cessionario'															, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U00'																	, ; //XA_ALIAS
	'2'																		, ; //XA_ORDEM
	'Vendedor'																, ; //XA_DESCRIC
	'Vendedor'																, ; //XA_DESCSPA
	'Vendedor'																, ; //XA_DESCENG
	'A03'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U00'																	, ; //XA_ALIAS
	'3'																		, ; //XA_ORDEM
	'Endereco'																, ; //XA_DESCRIC
	'Endereco'																, ; //XA_DESCSPA
	'Endereco'																, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U00'																	, ; //XA_ALIAS
	'3'																		, ; //XA_ORDEM
	'Dados do Contrato'														, ; //XA_DESCRIC
	'Dados do Contrato'														, ; //XA_DESCSPA
	'Dados do Contrato'														, ; //XA_DESCENG
	'A01'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U00'																	, ; //XA_ALIAS
	'4'																		, ; //XA_ORDEM
	'Endereco cobranca'														, ; //XA_DESCRIC
	'Endereco cobranca'														, ; //XA_DESCSPA
	'Endereco cobranca'														, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U00'																	, ; //XA_ALIAS
	'4'																		, ; //XA_ORDEM
	'Cancelamento'															, ; //XA_DESCRIC
	'Cancelamento'															, ; //XA_DESCSPA
	'Cancelamento'															, ; //XA_DESCENG
	'A04'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U00'																	, ; //XA_ALIAS
	'5'																		, ; //XA_ORDEM
	'Financeiro'															, ; //XA_DESCRIC
	'Financeiro'															, ; //XA_DESCSPA
	'Financeiro'															, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U00'																	, ; //XA_ALIAS
	'5'																		, ; //XA_ORDEM
	'Usuario'																, ; //XA_DESCRIC
	'Usuario'																, ; //XA_DESCSPA
	'Usuario'																, ; //XA_DESCENG
	'A06'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U00'																	, ; //XA_ALIAS
	'6'																		, ; //XA_ORDEM
	'Retirada das cinzas'													, ; //XA_DESCRIC
	'Retirada das cinzas'													, ; //XA_DESCSPA
	'Retirada das cinzas'													, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U00'																	, ; //XA_ALIAS
	'6'																		, ; //XA_ORDEM
	'Administradora de Planos'												, ; //XA_DESCRIC
	'Administradora de Planos'												, ; //XA_DESCSPA
	'Administradora de Planos'												, ; //XA_DESCENG
	'A08'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U00'																	, ; //XA_ALIAS
	'7'																		, ; //XA_ORDEM
	'Negociacao'															, ; //XA_DESCRIC
	'Negociacao'															, ; //XA_DESCSPA
	'Negociacao'															, ; //XA_DESCENG
	'A07'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U00'																	, ; //XA_ALIAS
	'8'																		, ; //XA_ORDEM
	'Reajuste'																, ; //XA_DESCRIC
	'Reajuste'																, ; //XA_DESCSPA
	'Reajuste'																, ; //XA_DESCENG
	'A09'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U00'																	, ; //XA_ALIAS
	'9'																		, ; //XA_ORDEM
	'Taxa de Manutencao'													, ; //XA_DESCRIC
	'Taxa de Manutencao'													, ; //XA_DESCSPA
	'Taxa de Manutencao'													, ; //XA_DESCENG
	'A10'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U00'																	, ; //XA_ALIAS
	'A'																		, ; //XA_ORDEM
	'Natureza Financeira'													, ; //XA_DESCRIC
	'Natureza Financeira'													, ; //XA_DESCSPA
	'Natureza Financeira'													, ; //XA_DESCENG
	'A11'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U00'																	, ; //XA_ALIAS
	'B'																		, ; //XA_ORDEM
	'Tabela de Preco'														, ; //XA_DESCRIC
	'Tabela de Preco'														, ; //XA_DESCSPA
	'Tabela de Preco'														, ; //XA_DESCENG
	'A12'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U00'																	, ; //XA_ALIAS
	'C'																		, ; //XA_ORDEM
	'Integracao Virtus'														, ; //XA_DESCRIC
	'Integracao Virtus'														, ; //XA_DESCSPA
	'Integracao Virtus'														, ; //XA_DESCENG
	'A13'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

//
// Tabela U05
//
aAdd( aSXA, { ;
	'U05'																	, ; //XA_ALIAS
	'1'																		, ; //XA_ORDEM
	'Cadastrais'															, ; //XA_DESCRIC
	'Cadastrais'															, ; //XA_DESCSPA
	'Cadastrais'															, ; //XA_DESCENG
	'A01'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U05'																	, ; //XA_ALIAS
	'1'																		, ; //XA_ORDEM
	'Tabela de Preco do Plano'												, ; //XA_DESCRIC
	'Tabela de Preco do Plano'												, ; //XA_DESCSPA
	'Tabela de Preco do Plano'												, ; //XA_DESCENG
	'A05'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U05'																	, ; //XA_ALIAS
	'2'																		, ; //XA_ORDEM
	'Vigencia'																, ; //XA_DESCRIC
	'Vigencia'																, ; //XA_DESCSPA
	'Vigencia'																, ; //XA_DESCENG
	'A02'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U05'																	, ; //XA_ALIAS
	'3'																		, ; //XA_ORDEM
	'Contratuais'															, ; //XA_DESCRIC
	'Contratuais'															, ; //XA_DESCSPA
	'Contratuais'															, ; //XA_DESCENG
	'A03'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U05'																	, ; //XA_ALIAS
	'4'																		, ; //XA_ORDEM
	'Financeiro'															, ; //XA_DESCRIC
	'Financeiro'															, ; //XA_DESCSPA
	'Financeiro'															, ; //XA_DESCENG
	'A04'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U05'																	, ; //XA_ALIAS
	'5'																		, ; //XA_ORDEM
	'Taxa de Manutencao'													, ; //XA_DESCRIC
	'Taxa de Manutencao'													, ; //XA_DESCSPA
	'Taxa de Manutencao'													, ; //XA_DESCENG
	'A06'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U05'																	, ; //XA_ALIAS
	'6'																		, ; //XA_ORDEM
	'Tabela de Preco'														, ; //XA_DESCRIC
	'Tabela de Preco'														, ; //XA_DESCSPA
	'Tabela de Preco'														, ; //XA_DESCENG
	'A07'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

//
// Tabela U08
//
aAdd( aSXA, { ;
	'U08'																	, ; //XA_ALIAS
	'1'																		, ; //XA_ORDEM
	'Dados Cadastrais'														, ; //XA_DESCRIC
	'Dados Cadastrais'														, ; //XA_DESCSPA
	'Dados Cadastrais'														, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U08'																	, ; //XA_ALIAS
	'2'																		, ; //XA_ORDEM
	'Dados do Mapa'															, ; //XA_DESCRIC
	'Dados do Mapa'															, ; //XA_DESCSPA
	'Dados do Mapa'															, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

//
// Tabela U15
//
aAdd( aSXA, { ;
	'U15'																	, ; //XA_ALIAS
	'1'																		, ; //XA_ORDEM
	'Cadastrais'															, ; //XA_DESCRIC
	'Cadastrais'															, ; //XA_DESCSPA
	'Cadastrais'															, ; //XA_DESCENG
	'A01'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U15'																	, ; //XA_ALIAS
	'2'																		, ; //XA_ORDEM
	'Categorização'															, ; //XA_DESCRIC
	'Categorização'															, ; //XA_DESCSPA
	'Categorização'															, ; //XA_DESCENG
	'A02'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U15'																	, ; //XA_ALIAS
	'3'																		, ; //XA_ORDEM
	'Parcelas Recebidas'													, ; //XA_DESCRIC
	'Parcelas Recebidas'													, ; //XA_DESCSPA
	'Parcelas Recebidas'													, ; //XA_DESCENG
	'A03'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

//
// Tabela U25
//
aAdd( aSXA, { ;
	'U25'																	, ; //XA_ALIAS
	'1'																		, ; //XA_ORDEM
	'Sala Velorio'															, ; //XA_DESCRIC
	'Sala Velorio'															, ; //XA_DESCSPA
	'Sala Velorio'															, ; //XA_DESCENG
	'A01'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U25'																	, ; //XA_ALIAS
	'2'																		, ; //XA_ORDEM
	'Dados Reserva'															, ; //XA_DESCRIC
	'Dados Reserva'															, ; //XA_DESCSPA
	'Dados Reserva'															, ; //XA_DESCENG
	'A02'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

//
// Tabela U32
//
aAdd( aSXA, { ;
	'U32'																	, ; //XA_ALIAS
	'1'																		, ; //XA_ORDEM
	'Cadastrais'															, ; //XA_DESCRIC
	'Cadastrais'															, ; //XA_DESCSPA
	'Cadastrais'															, ; //XA_DESCENG
	'A01'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U32'																	, ; //XA_ALIAS
	'2'																		, ; //XA_ORDEM
	'Dados do Cliente'														, ; //XA_DESCRIC
	'Dados do Cliente'														, ; //XA_DESCSPA
	'Dados do Cliente'														, ; //XA_DESCENG
	'A02'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U32'																	, ; //XA_ALIAS
	'3'																		, ; //XA_ORDEM
	'Dados da Entrega'														, ; //XA_DESCRIC
	'Dados da Entrega'														, ; //XA_DESCSPA
	'Dados da Entrega'														, ; //XA_DESCENG
	'A03'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U32'																	, ; //XA_ALIAS
	'4'																		, ; //XA_ORDEM
	'Itens da Entrega'														, ; //XA_DESCRIC
	'Itens da Entrega'														, ; //XA_DESCSPA
	'Itens da Entrega'														, ; //XA_DESCENG
	'A04'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U32'																	, ; //XA_ALIAS
	'5'																		, ; //XA_ORDEM
	'Entregador'															, ; //XA_DESCRIC
	'Entregador'															, ; //XA_DESCSPA
	'Entregador'															, ; //XA_DESCENG
	'A05'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U32'																	, ; //XA_ALIAS
	'6'																		, ; //XA_ORDEM
	'Dados da Rota'															, ; //XA_DESCRIC
	'Dados da Rota'															, ; //XA_DESCSPA
	'Dados da Rota'															, ; //XA_DESCENG
	'A06'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U32'																	, ; //XA_ALIAS
	'7'																		, ; //XA_ORDEM
	'Referencia Inicial e Final'											, ; //XA_DESCRIC
	'Referencia Inicial e Final'											, ; //XA_DESCSPA
	'Referencia Inicial e Final'											, ; //XA_DESCENG
	'A07'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

//
// Tabela U38
//
aAdd( aSXA, { ;
	'U38'																	, ; //XA_ALIAS
	'1'																		, ; //XA_ORDEM
	'Cadastrais'															, ; //XA_DESCRIC
	'Cadastrais'															, ; //XA_DESCSPA
	'Cadastrais'															, ; //XA_DESCENG
	'A01'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U38'																	, ; //XA_ALIAS
	'1'																		, ; //XA_ORDEM
	'Cadastrais'															, ; //XA_DESCRIC
	'Cadastrais'															, ; //XA_DESCSPA
	'Cadastrais'															, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U38'																	, ; //XA_ALIAS
	'2'																		, ; //XA_ORDEM
	'Contrato Origem'														, ; //XA_DESCRIC
	'Contrato Origem'														, ; //XA_DESCSPA
	'Contrato Origem'														, ; //XA_DESCENG
	'A02'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U38'																	, ; //XA_ALIAS
	'2'																		, ; //XA_ORDEM
	'Origem'																, ; //XA_DESCRIC
	'Origem'																, ; //XA_DESCSPA
	'Origem'																, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U38'																	, ; //XA_ALIAS
	'3'																		, ; //XA_ORDEM
	'Contrato Destino'														, ; //XA_DESCRIC
	'Contrato Destino'														, ; //XA_DESCSPA
	'Contrato Destino'														, ; //XA_DESCENG
	'A03'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U38'																	, ; //XA_ALIAS
	'3'																		, ; //XA_ORDEM
	'Destino'																, ; //XA_DESCRIC
	'Destino'																, ; //XA_DESCSPA
	'Destino'																, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U38'																	, ; //XA_ALIAS
	'4'																		, ; //XA_ORDEM
	'Observaçao'															, ; //XA_DESCRIC
	'Observaçao'															, ; //XA_DESCSPA
	'Observaçao'															, ; //XA_DESCENG
	'A04'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U38'																	, ; //XA_ALIAS
	'5'																		, ; //XA_ORDEM
	'Servico Origem'														, ; //XA_DESCRIC
	'Servico Origem'														, ; //XA_DESCSPA
	'Servico Origem'														, ; //XA_DESCENG
	'A05'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U38'																	, ; //XA_ALIAS
	'6'																		, ; //XA_ORDEM
	'Obito'																	, ; //XA_DESCRIC
	'Obito'																	, ; //XA_DESCSPA
	'Obito'																	, ; //XA_DESCENG
	'A06'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U38'																	, ; //XA_ALIAS
	'7'																		, ; //XA_ORDEM
	'Endereco Jazigo'														, ; //XA_DESCRIC
	'Endereco Jazigo'														, ; //XA_DESCSPA
	'Endereco Jazigo'														, ; //XA_DESCENG
	'A07'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U38'																	, ; //XA_ALIAS
	'8'																		, ; //XA_ORDEM
	'Endereco Ossario'														, ; //XA_DESCRIC
	'Endereco Ossario'														, ; //XA_DESCSPA
	'Endereco Ossario'														, ; //XA_DESCENG
	'A08'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U38'																	, ; //XA_ALIAS
	'9'																		, ; //XA_ORDEM
	'Autorizado'															, ; //XA_DESCRIC
	'Autorizado'															, ; //XA_DESCSPA
	'Autorizado'															, ; //XA_DESCENG
	'A09'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U38'																	, ; //XA_ALIAS
	'A'																		, ; //XA_ORDEM
	'Servico Destino'														, ; //XA_DESCRIC
	'Servico Destino'														, ; //XA_DESCSPA
	'Servico Destino'														, ; //XA_DESCENG
	'A10'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U38'																	, ; //XA_ALIAS
	'B'																		, ; //XA_ORDEM
	'Endereco Jazigo'														, ; //XA_DESCRIC
	'Endereco Jazigo'														, ; //XA_DESCSPA
	'Endereco Jazigo'														, ; //XA_DESCENG
	'A11'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U38'																	, ; //XA_ALIAS
	'C'																		, ; //XA_ORDEM
	'Endereço Crematorio'													, ; //XA_DESCRIC
	'Endereço Crematorio'													, ; //XA_DESCSPA
	'Endereço Crematorio'													, ; //XA_DESCENG
	'A12'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U38'																	, ; //XA_ALIAS
	'D'																		, ; //XA_ORDEM
	'Endereco Ossario'														, ; //XA_DESCRIC
	'Endereco Ossario'														, ; //XA_DESCSPA
	'Endereco Ossario'														, ; //XA_DESCENG
	'A13'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U38'																	, ; //XA_ALIAS
	'E'																		, ; //XA_ORDEM
	'Tipo de Transferencia'													, ; //XA_DESCRIC
	'Tipo de Transferencia'													, ; //XA_DESCSPA
	'Tipo de Transferencia'													, ; //XA_DESCENG
	'A15'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

//
// Tabela U43
//
aAdd( aSXA, { ;
	'U43'																	, ; //XA_ALIAS
	'1'																		, ; //XA_ORDEM
	'Personalizacao'														, ; //XA_DESCRIC
	'Personalizacao'														, ; //XA_DESCSPA
	'Personalizacao'														, ; //XA_DESCENG
	'A01'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U43'																	, ; //XA_ALIAS
	'2'																		, ; //XA_ORDEM
	'Dados do Usuario'														, ; //XA_DESCRIC
	'Dados do Usuario'														, ; //XA_DESCSPA
	'Dados do Usuario'														, ; //XA_DESCENG
	'A02'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U43'																	, ; //XA_ALIAS
	'3'																		, ; //XA_ORDEM
	'Plano Atual do Contrato'												, ; //XA_DESCRIC
	'Plano Atual do Contrato'												, ; //XA_DESCSPA
	'Plano Atual do Contrato'												, ; //XA_DESCENG
	'A03'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U43'																	, ; //XA_ALIAS
	'4'																		, ; //XA_ORDEM
	'Novo Plano do Contrato'												, ; //XA_DESCRIC
	'Novo Plano do Contrato'												, ; //XA_DESCSPA
	'Novo Plano do Contrato'												, ; //XA_DESCENG
	'A04'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U43'																	, ; //XA_ALIAS
	'5'																		, ; //XA_ORDEM
	'Tabela de Preco'														, ; //XA_DESCRIC
	'Tabela de Preco'														, ; //XA_DESCSPA
	'Tabela de Preco'														, ; //XA_DESCENG
	'A05'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

//
// Tabela U62
//
aAdd( aSXA, { ;
	'U62'																	, ; //XA_ALIAS
	'1'																		, ; //XA_ORDEM
	'Dados da Integracao'													, ; //XA_DESCRIC
	'Dados da Integracao'													, ; //XA_DESCSPA
	'Dados da Integracao'													, ; //XA_DESCENG
	'A'																		, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U62'																	, ; //XA_ALIAS
	'2'																		, ; //XA_ORDEM
	'Entidade'																, ; //XA_DESCRIC
	'Entidade'																, ; //XA_DESCSPA
	'Entidade'																, ; //XA_DESCENG
	'B'																		, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U62'																	, ; //XA_ALIAS
	'3'																		, ; //XA_ORDEM
	'Envio'																	, ; //XA_DESCRIC
	'Envio'																	, ; //XA_DESCSPA
	'Envio'																	, ; //XA_DESCENG
	'C'																		, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U62'																	, ; //XA_ALIAS
	'4'																		, ; //XA_ORDEM
	'Retorno'																, ; //XA_DESCRIC
	'Retorno'																, ; //XA_DESCSPA
	'Retorno'																, ; //XA_DESCENG
	'D'																		, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

//
// Tabela U64
//
aAdd( aSXA, { ;
	'U64'																	, ; //XA_ALIAS
	'1'																		, ; //XA_ORDEM
	'Dados do Perfil'														, ; //XA_DESCRIC
	'Dados do Perfil'														, ; //XA_DESCSPA
	'Dados do Perfil'														, ; //XA_DESCENG
	'A'																		, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U64'																	, ; //XA_ALIAS
	'2'																		, ; //XA_ORDEM
	'Cliente'																, ; //XA_DESCRIC
	'Cliente'																, ; //XA_DESCSPA
	'Cliente'																, ; //XA_DESCENG
	'B'																		, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U64'																	, ; //XA_ALIAS
	'3'																		, ; //XA_ORDEM
	'Forma de Pagamento'													, ; //XA_DESCRIC
	'Forma de Pagamento'													, ; //XA_DESCSPA
	'Forma de Pagamento'													, ; //XA_DESCENG
	'C'																		, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U64'																	, ; //XA_ALIAS
	'4'																		, ; //XA_ORDEM
	'Dados do Cartao'														, ; //XA_DESCRIC
	'Dados do Cartao'														, ; //XA_DESCSPA
	'Dados do Cartao'														, ; //XA_DESCENG
	'D'																		, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

//
// Tabela U68
//
aAdd( aSXA, { ;
	'U68'																	, ; //XA_ALIAS
	'1'																		, ; //XA_ORDEM
	'Dados Alteracao'														, ; //XA_DESCRIC
	'Dados Alteracao'														, ; //XA_DESCSPA
	'Dados Alteracao'														, ; //XA_DESCENG
	'A'																		, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U68'																	, ; //XA_ALIAS
	'2'																		, ; //XA_ORDEM
	'Dados do Contrato'														, ; //XA_DESCRIC
	'Dados do Contrato'														, ; //XA_DESCSPA
	'Dados do Contrato'														, ; //XA_DESCENG
	'B'																		, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'U68'																	, ; //XA_ALIAS
	'3'																		, ; //XA_ORDEM
	'Dados do Usuario'														, ; //XA_DESCRIC
	'Dados do Usuario'														, ; //XA_DESCSPA
	'Dados do Usuario'														, ; //XA_DESCENG
	'C'																		, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

//
// Tabela UF0
//
aAdd( aSXA, { ;
	'UF0'																	, ; //XA_ALIAS
	'1'																		, ; //XA_ORDEM
	'Cadastrais'															, ; //XA_DESCRIC
	'Cadastrais'															, ; //XA_DESCSPA
	'Cadastrais'															, ; //XA_DESCENG
	'A01'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UF0'																	, ; //XA_ALIAS
	'2'																		, ; //XA_ORDEM
	'Vigencia'																, ; //XA_DESCRIC
	'Vigencia'																, ; //XA_DESCSPA
	'Vigencia'																, ; //XA_DESCENG
	'A02'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UF0'																	, ; //XA_ALIAS
	'3'																		, ; //XA_ORDEM
	'Carencia'																, ; //XA_DESCRIC
	'Carencia'																, ; //XA_DESCSPA
	'Carencia'																, ; //XA_DESCENG
	'A03'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UF0'																	, ; //XA_ALIAS
	'4'																		, ; //XA_ORDEM
	'Financeiro'															, ; //XA_DESCRIC
	'Financeiro'															, ; //XA_DESCSPA
	'Financeiro'															, ; //XA_DESCENG
	'A04'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UF0'																	, ; //XA_ALIAS
	'5'																		, ; //XA_ORDEM
	'Seguro'																, ; //XA_DESCRIC
	'Seguro'																, ; //XA_DESCSPA
	'Seguro'																, ; //XA_DESCENG
	'A05'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UF0'																	, ; //XA_ALIAS
	'6'																		, ; //XA_ORDEM
	'Regras de Contrato'													, ; //XA_DESCRIC
	'Regras de Contrato'													, ; //XA_DESCSPA
	'Regras de Contrato'													, ; //XA_DESCENG
	'A07'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UF0'																	, ; //XA_ALIAS
	'7'																		, ; //XA_ORDEM
	'Tabela de Preço'														, ; //XA_DESCRIC
	'Tabela de Preço'														, ; //XA_DESCSPA
	'Tabela de Preço'														, ; //XA_DESCENG
	'A06'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UF0'																	, ; //XA_ALIAS
	'9'																		, ; //XA_ORDEM
	'Comissionamento'														, ; //XA_DESCRIC
	'Comissionamento'														, ; //XA_DESCSPA
	'Comissionamento'														, ; //XA_DESCENG
	'A09'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

//
// Tabela UF2
//
aAdd( aSXA, { ;
	'UF2'																	, ; //XA_ALIAS
	'1'																		, ; //XA_ORDEM
	'Dados'																	, ; //XA_DESCRIC
	'Dados'																	, ; //XA_DESCSPA
	'Dados'																	, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UF2'																	, ; //XA_ALIAS
	'1'																		, ; //XA_ORDEM
	'Dados do Plano'														, ; //XA_DESCRIC
	'Dados do Plano'														, ; //XA_DESCSPA
	'Dados do Plano'														, ; //XA_DESCENG
	'A01'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UF2'																	, ; //XA_ALIAS
	'2'																		, ; //XA_ORDEM
	'Titular'																, ; //XA_DESCRIC
	'Titular'																, ; //XA_DESCSPA
	'Titular'																, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UF2'																	, ; //XA_ALIAS
	'2'																		, ; //XA_ORDEM
	'Dados do Contrato'														, ; //XA_DESCRIC
	'Dados do Contrato'														, ; //XA_DESCSPA
	'Dados do Contrato'														, ; //XA_DESCENG
	'A02'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UF2'																	, ; //XA_ALIAS
	'3'																		, ; //XA_ORDEM
	'Endereco'																, ; //XA_DESCRIC
	'Endereco'																, ; //XA_DESCSPA
	'Endereco'																, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UF2'																	, ; //XA_ALIAS
	'3'																		, ; //XA_ORDEM
	'Vendedor'																, ; //XA_DESCRIC
	'Vendedor'																, ; //XA_DESCSPA
	'Vendedor'																, ; //XA_DESCENG
	'A03'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UF2'																	, ; //XA_ALIAS
	'4'																		, ; //XA_ORDEM
	'Endereco Cobranca'														, ; //XA_DESCRIC
	'Endereco Cobranca'														, ; //XA_DESCSPA
	'Endereco Cobranca'														, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UF2'																	, ; //XA_ALIAS
	'4'																		, ; //XA_ORDEM
	'Cancelamento'															, ; //XA_DESCRIC
	'Cancelamento'															, ; //XA_DESCSPA
	'Cancelamento'															, ; //XA_DESCENG
	'A04'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UF2'																	, ; //XA_ALIAS
	'5'																		, ; //XA_ORDEM
	'Financeiro'															, ; //XA_DESCRIC
	'Financeiro'															, ; //XA_DESCSPA
	'Financeiro'															, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UF2'																	, ; //XA_ALIAS
	'5'																		, ; //XA_ORDEM
	'Usuario'																, ; //XA_DESCRIC
	'Usuario'																, ; //XA_DESCSPA
	'Usuario'																, ; //XA_DESCENG
	'A05'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UF2'																	, ; //XA_ALIAS
	'6'																		, ; //XA_ORDEM
	'Administradora de Planos'												, ; //XA_DESCRIC
	'Administradora de Planos'												, ; //XA_DESCSPA
	'Administradora de Planos'												, ; //XA_DESCENG
	'A06'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UF2'																	, ; //XA_ALIAS
	'6'																		, ; //XA_ORDEM
	'Auditoria'																, ; //XA_DESCRIC
	'Auditoria'																, ; //XA_DESCSPA
	'Auditoria'																, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UF2'																	, ; //XA_ALIAS
	'7'																		, ; //XA_ORDEM
	'Seguro'																, ; //XA_DESCRIC
	'Seguro'																, ; //XA_DESCSPA
	'Seguro'																, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UF2'																	, ; //XA_ALIAS
	'7'																		, ; //XA_ORDEM
	'Valores e Cobrancas Adicionais'										, ; //XA_DESCRIC
	'Valores e Cobrancas Adicionais'										, ; //XA_DESCSPA
	'Valores e Cobrancas Adicionais'										, ; //XA_DESCENG
	'A14'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UF2'																	, ; //XA_ALIAS
	'8'																		, ; //XA_ORDEM
	'Negociacao'															, ; //XA_DESCRIC
	'Negociacao'															, ; //XA_DESCSPA
	'Negociacao'															, ; //XA_DESCENG
	'A07'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UF2'																	, ; //XA_ALIAS
	'8'																		, ; //XA_ORDEM
	'Transferência de Titularidade'											, ; //XA_DESCRIC
	'Transferência de Titularidade'											, ; //XA_DESCSPA
	'Transferência de Titularidade'											, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UF2'																	, ; //XA_ALIAS
	'9'																		, ; //XA_ORDEM
	'Reajuste e Taxa de Manutencao'											, ; //XA_DESCRIC
	'Reajuste e Taxa de Manutencao'											, ; //XA_DESCSPA
	'Reajuste e Taxa de Manutencao'											, ; //XA_DESCENG
	'A08'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UF2'																	, ; //XA_ALIAS
	'A'																		, ; //XA_ORDEM
	'Carência'																, ; //XA_DESCRIC
	'Carência'																, ; //XA_DESCSPA
	'Carência'																, ; //XA_DESCENG
	'A09'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UF2'																	, ; //XA_ALIAS
	'B'																		, ; //XA_ORDEM
	'Natureza Financeira'													, ; //XA_DESCRIC
	'Natureza Financeira'													, ; //XA_DESCSPA
	'Natureza Financeira'													, ; //XA_DESCENG
	'A10'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UF2'																	, ; //XA_ALIAS
	'C'																		, ; //XA_ORDEM
	'Tabela de Preco'														, ; //XA_DESCRIC
	'Tabela de Preco'														, ; //XA_DESCSPA
	'Tabela de Preco'														, ; //XA_DESCENG
	'A11'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UF2'																	, ; //XA_ALIAS
	'D'																		, ; //XA_ORDEM
	'Integracao Virtus'														, ; //XA_DESCRIC
	'Integracao Virtus'														, ; //XA_DESCSPA
	'Integracao Virtus'														, ; //XA_DESCENG
	'A13'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

//
// Tabela UH2
//
aAdd( aSXA, { ;
	'UH2'																	, ; //XA_ALIAS
	'1'																		, ; //XA_ORDEM
	'Personalizacao'														, ; //XA_DESCRIC
	'Personalizacao'														, ; //XA_DESCSPA
	'Personalizacao'														, ; //XA_DESCENG
	'A01'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UH2'																	, ; //XA_ALIAS
	'2'																		, ; //XA_ORDEM
	'Dados do Usuario'														, ; //XA_DESCRIC
	'Dados do Usuario'														, ; //XA_DESCSPA
	'Dados do Usuario'														, ; //XA_DESCENG
	'A02'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UH2'																	, ; //XA_ALIAS
	'3'																		, ; //XA_ORDEM
	'Plano Atual do Contrato'												, ; //XA_DESCRIC
	'Plano Atual do Contrato'												, ; //XA_DESCSPA
	'Plano Atual do Contrato'												, ; //XA_DESCENG
	'A03'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UH2'																	, ; //XA_ALIAS
	'4'																		, ; //XA_ORDEM
	'Novo Plano do Contrato'												, ; //XA_DESCRIC
	'Novo Plano do Contrato'												, ; //XA_DESCSPA
	'Novo Plano do Contrato'												, ; //XA_DESCENG
	'A04'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UH2'																	, ; //XA_ALIAS
	'5'																		, ; //XA_ORDEM
	'Tab. Preco Plano Selecionado'											, ; //XA_DESCRIC
	'Tab. Preco Plano Selecionado'											, ; //XA_DESCSPA
	'Tab. Preco Plano Selecionado'											, ; //XA_DESCENG
	'A05'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

//
// Tabela UI2
//
aAdd( aSXA, { ;
	'UI2'																	, ; //XA_ALIAS
	'1'																		, ; //XA_ORDEM
	'Dados do Seguro'														, ; //XA_DESCRIC
	'Dados do Seguro'														, ; //XA_DESCSPA
	'Dados do Seguro'														, ; //XA_DESCENG
	'A01'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UI2'																	, ; //XA_ALIAS
	'2'																		, ; //XA_ORDEM
	'Dados Contratuais'														, ; //XA_DESCRIC
	'Dados Contratuais'														, ; //XA_DESCSPA
	'Dados Contratuais'														, ; //XA_DESCENG
	'A02'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UI2'																	, ; //XA_ALIAS
	'3'																		, ; //XA_ORDEM
	'Regras de Repasse'														, ; //XA_DESCRIC
	'Regras de Repasse'														, ; //XA_DESCSPA
	'Regras de Repasse'														, ; //XA_DESCENG
	'A03'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

//
// Tabela UJ0
//
aAdd( aSXA, { ;
	'UJ0'																	, ; //XA_ALIAS
	'1'																		, ; //XA_ORDEM
	'Dados do Contrato'														, ; //XA_DESCRIC
	'Dados do Contrato'														, ; //XA_DESCSPA
	'Dados do Contrato'														, ; //XA_DESCENG
	'UM'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJ0'																	, ; //XA_ALIAS
	'1'																		, ; //XA_ORDEM
	'Cadastrais'															, ; //XA_DESCRIC
	'Cadastrais'															, ; //XA_DESCSPA
	'Cadastrais'															, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJ0'																	, ; //XA_ALIAS
	'2'																		, ; //XA_ORDEM
	'Plano Entregue'														, ; //XA_DESCRIC
	'Plano Entregue'														, ; //XA_DESCSPA
	'Plano Entregue'														, ; //XA_DESCENG
	'DOI'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJ0'																	, ; //XA_ALIAS
	'2'																		, ; //XA_ORDEM
	'Dados do Obito'														, ; //XA_DESCRIC
	'Dados do Obito'														, ; //XA_DESCSPA
	'Dados do Obito'														, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJ0'																	, ; //XA_ALIAS
	'3'																		, ; //XA_ORDEM
	'Mao de Obra'															, ; //XA_DESCRIC
	'Mao de Obra'															, ; //XA_DESCSPA
	'Mao de Obra'															, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJ0'																	, ; //XA_ALIAS
	'4'																		, ; //XA_ORDEM
	'Dados do PV - Cliente'													, ; //XA_DESCRIC
	'Dados do PV - Cliente'													, ; //XA_DESCSPA
	'Dados do PV - Cliente'													, ; //XA_DESCENG
	'QUA'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJ0'																	, ; //XA_ALIAS
	'4'																		, ; //XA_ORDEM
	'Pedido de Venda - Cliente'												, ; //XA_DESCRIC
	'Pedido de Venda - Cliente'												, ; //XA_DESCSPA
	'Pedido de Venda - Cliente'												, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJ0'																	, ; //XA_ALIAS
	'5'																		, ; //XA_ORDEM
	'Dados do PV - Adm. de planos'											, ; //XA_DESCRIC
	'Dados do PV - Adm. de planos'											, ; //XA_DESCSPA
	'Dados do PV - Adm. de planos'											, ; //XA_DESCENG
	'CIN'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJ0'																	, ; //XA_ALIAS
	'5'																		, ; //XA_ORDEM
	'Pedido de Venda - Adm Planos'											, ; //XA_DESCRIC
	'Pedido de Venda - Adm Planos'											, ; //XA_DESCSPA
	'Pedido de Venda - Adm Planos'											, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJ0'																	, ; //XA_ALIAS
	'6'																		, ; //XA_ORDEM
	'Dados da OS'															, ; //XA_DESCRIC
	'Dados da OS'															, ; //XA_DESCSPA
	'Dados da OS'															, ; //XA_DESCENG
	'SEI'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJ0'																	, ; //XA_ALIAS
	'6'																		, ; //XA_ORDEM
	'Auditoria'																, ; //XA_DESCRIC
	'Auditoria'																, ; //XA_DESCSPA
	'Auditoria'																, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJ0'																	, ; //XA_ALIAS
	'7'																		, ; //XA_ORDEM
	'Dados Obito'															, ; //XA_DESCRIC
	'Dados Obito'															, ; //XA_DESCSPA
	'Dados Obito'															, ; //XA_DESCENG
	'SET'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJ0'																	, ; //XA_ALIAS
	'7'																		, ; //XA_ORDEM
	'Cancelamento'															, ; //XA_DESCRIC
	'Cancelamento'															, ; //XA_DESCSPA
	'Cancelamento'															, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJ0'																	, ; //XA_ALIAS
	'8'																		, ; //XA_ORDEM
	'Remocao'																, ; //XA_DESCRIC
	'Remocao'																, ; //XA_DESCSPA
	'Remocao'																, ; //XA_DESCENG
	'OIT'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJ0'																	, ; //XA_ALIAS
	'8'																		, ; //XA_ORDEM
	'Dados do Seguro'														, ; //XA_DESCRIC
	'Dados do Seguro'														, ; //XA_DESCSPA
	'Dados do Seguro'														, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJ0'																	, ; //XA_ALIAS
	'A'																		, ; //XA_ORDEM
	'Dados do Usuario de Inclusao'											, ; //XA_DESCRIC
	'Dados do Usuario de Inclusao'											, ; //XA_DESCSPA
	'Dados do Usuario de Inclusao'											, ; //XA_DESCENG
	'DEZ'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJ0'																	, ; //XA_ALIAS
	'B'																		, ; //XA_ORDEM
	'Velorio'																, ; //XA_DESCRIC
	'Velorio'																, ; //XA_DESCSPA
	'Velorio'																, ; //XA_DESCENG
	'ONZ'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJ0'																	, ; //XA_ALIAS
	'C'																		, ; //XA_ORDEM
	'Cortejo'																, ; //XA_DESCRIC
	'Cortejo'																, ; //XA_DESCSPA
	'Cortejo'																, ; //XA_DESCENG
	'DOZ'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJ0'																	, ; //XA_ALIAS
	'D'																		, ; //XA_ORDEM
	'Unidade de Atendimento'												, ; //XA_DESCRIC
	'Unidade de Atendimento'												, ; //XA_DESCSPA
	'Unidade de Atendimento'												, ; //XA_DESCENG
	'QUZ'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJ0'																	, ; //XA_ALIAS
	'E'																		, ; //XA_ORDEM
	'Sepultamento'															, ; //XA_DESCRIC
	'Sepultamento'															, ; //XA_DESCSPA
	'Sepultamento'															, ; //XA_DESCENG
	'TRE'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJ0'																	, ; //XA_ALIAS
	'E'																		, ; //XA_ORDEM
	'Valores'																, ; //XA_DESCRIC
	'Valores'																, ; //XA_DESCSPA
	'Valores'																, ; //XA_DESCENG
	'QRT'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJ0'																	, ; //XA_ALIAS
	'F'																		, ; //XA_ORDEM
	'Profissionais'															, ; //XA_DESCRIC
	'Profissionais'															, ; //XA_DESCSPA
	'Profissionais'															, ; //XA_DESCENG
	'NOV'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJ0'																	, ; //XA_ALIAS
	'G'																		, ; //XA_ORDEM
	'Dados da Auditoria'													, ; //XA_DESCRIC
	'Dados da Auditoria'													, ; //XA_DESCSPA
	'Dados da Auditoria'													, ; //XA_DESCENG
	'AUD'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJ0'																	, ; //XA_ALIAS
	'H'																		, ; //XA_ORDEM
	'Dados do Cancelamento'													, ; //XA_DESCRIC
	'Dados do Cancelamento'													, ; //XA_DESCSPA
	'Dados do Cancelamento'													, ; //XA_DESCENG
	'CAN'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJ0'																	, ; //XA_ALIAS
	'I'																		, ; //XA_ORDEM
	'Tabela de Preco'														, ; //XA_DESCRIC
	'Tabela de Preco'														, ; //XA_DESCSPA
	'Tabela de Preco'														, ; //XA_DESCENG
	'TAB'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

//
// Tabela UJC
//
aAdd( aSXA, { ;
	'UJC'																	, ; //XA_ALIAS
	'1'																		, ; //XA_ORDEM
	'Cadastrais'															, ; //XA_DESCRIC
	'Cadastrais'															, ; //XA_DESCSPA
	'Cadastrais'															, ; //XA_DESCENG
	'A01'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJC'																	, ; //XA_ALIAS
	'2'																		, ; //XA_ORDEM
	'Localizacao'															, ; //XA_DESCRIC
	'Localizacao'															, ; //XA_DESCSPA
	'Localizacao'															, ; //XA_DESCENG
	'A02'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

//
// Tabela UJD
//
aAdd( aSXA, { ;
	'UJD'																	, ; //XA_ALIAS
	'1'																		, ; //XA_ORDEM
	'Cadastrais'															, ; //XA_DESCRIC
	'Cadastrais'															, ; //XA_DESCSPA
	'Cadastrais'															, ; //XA_DESCENG
	'A01'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJD'																	, ; //XA_ALIAS
	'2'																		, ; //XA_ORDEM
	'Localizacao'															, ; //XA_DESCRIC
	'Localizacao'															, ; //XA_DESCSPA
	'Localizacao'															, ; //XA_DESCENG
	'A02'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

//
// Tabela UJE
//
aAdd( aSXA, { ;
	'UJE'																	, ; //XA_ALIAS
	'1'																		, ; //XA_ORDEM
	'Cadastrais'															, ; //XA_DESCRIC
	'Cadastrais'															, ; //XA_DESCSPA
	'Cadastrais'															, ; //XA_DESCENG
	'A01'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJE'																	, ; //XA_ALIAS
	'2'																		, ; //XA_ORDEM
	'Localizacao'															, ; //XA_DESCRIC
	'Localizacao'															, ; //XA_DESCSPA
	'Localizacao'															, ; //XA_DESCENG
	'A02'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

//
// Tabela UJF
//
aAdd( aSXA, { ;
	'UJF'																	, ; //XA_ALIAS
	'1'																		, ; //XA_ORDEM
	'Dados apontamento de servico'											, ; //XA_DESCRIC
	'Dados apontamento de servico'											, ; //XA_DESCSPA
	'Dados apontamento de servico'											, ; //XA_DESCENG
	'APT'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJF'																	, ; //XA_ALIAS
	'2'																		, ; //XA_ORDEM
	'Dados solicitacao'														, ; //XA_DESCRIC
	'Dados solicitacao'														, ; //XA_DESCSPA
	'Dados solicitacao'														, ; //XA_DESCENG
	'SOL'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

//
// Tabela UJH
//
aAdd( aSXA, { ;
	'UJH'																	, ; //XA_ALIAS
	'1'																		, ; //XA_ORDEM
	'Dados Contrato'														, ; //XA_DESCRIC
	'Dados Contrato'														, ; //XA_DESCSPA
	'Dados Contrato'														, ; //XA_DESCENG
	'A01'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJH'																	, ; //XA_ALIAS
	'2'																		, ; //XA_ORDEM
	'Dados Pagamento'														, ; //XA_DESCRIC
	'Dados Pagamento'														, ; //XA_DESCSPA
	'Dados Pagamento'														, ; //XA_DESCENG
	'A02'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJH'																	, ; //XA_ALIAS
	'3'																		, ; //XA_ORDEM
	'Usuario Inclusao/Retorno'												, ; //XA_DESCRIC
	'Usuario Inclusao'														, ; //XA_DESCSPA
	'Usuario Inclusao'														, ; //XA_DESCENG
	'A03'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJH'																	, ; //XA_ALIAS
	'4'																		, ; //XA_ORDEM
	'Valores'																, ; //XA_DESCRIC
	'Valores'																, ; //XA_DESCSPA
	'Valores'																, ; //XA_DESCENG
	'A04'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

//
// Tabela UJJ
//
aAdd( aSXA, { ;
	'UJJ'																	, ; //XA_ALIAS
	'1'																		, ; //XA_ORDEM
	'Cadastrais'															, ; //XA_DESCRIC
	'Cadastrais'															, ; //XA_DESCSPA
	'Cadastrais'															, ; //XA_DESCENG
	'A01'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJJ'																	, ; //XA_ALIAS
	'2'																		, ; //XA_ORDEM
	'Arquivo Modelo'														, ; //XA_DESCRIC
	'Arquivo Modelo'														, ; //XA_DESCSPA
	'Arquivo Modelo'														, ; //XA_DESCENG
	'A02'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJJ'																	, ; //XA_ALIAS
	'3'																		, ; //XA_ORDEM
	'Rotina'																, ; //XA_DESCRIC
	'Rotina'																, ; //XA_DESCSPA
	'Rotina'																, ; //XA_DESCENG
	'A04'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJJ'																	, ; //XA_ALIAS
	'4'																		, ; //XA_ORDEM
	'Status'																, ; //XA_DESCRIC
	'Status'																, ; //XA_DESCSPA
	'Status'																, ; //XA_DESCENG
	'A03'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

//
// Tabela UJN
//
aAdd( aSXA, { ;
	'UJN'																	, ; //XA_ALIAS
	'1'																		, ; //XA_ORDEM
	'Cadastrais'															, ; //XA_DESCRIC
	'Cadastrais'															, ; //XA_DESCSPA
	'Cadastrais'															, ; //XA_DESCENG
	'A01'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJN'																	, ; //XA_ALIAS
	'2'																		, ; //XA_ORDEM
	'Rotina'																, ; //XA_DESCRIC
	'Rotina'																, ; //XA_DESCSPA
	'Rotina'																, ; //XA_DESCENG
	'A02'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJN'																	, ; //XA_ALIAS
	'3'																		, ; //XA_ORDEM
	'Tabela'																, ; //XA_DESCRIC
	'Tabela'																, ; //XA_DESCSPA
	'Tabela'																, ; //XA_DESCENG
	'A03'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJN'																	, ; //XA_ALIAS
	'4'																		, ; //XA_ORDEM
	'Indice do Termo'														, ; //XA_DESCRIC
	'Indice do Termo'														, ; //XA_DESCSPA
	'Indice do Termo'														, ; //XA_DESCENG
	'A04'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJN'																	, ; //XA_ALIAS
	'5'																		, ; //XA_ORDEM
	'Consulta Padrao'														, ; //XA_DESCRIC
	'Consulta Padrao'														, ; //XA_DESCSPA
	'Consulta Padrao'														, ; //XA_DESCENG
	'A05'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

//
// Tabela UJV
//
aAdd( aSXA, { ;
	'UJV'																	, ; //XA_ALIAS
	'1'																		, ; //XA_ORDEM
	'Cadastrais'															, ; //XA_DESCRIC
	'Cadastrais'															, ; //XA_DESCSPA
	'Cadastrais'															, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJV'																	, ; //XA_ALIAS
	'2'																		, ; //XA_ORDEM
	'Dados Obito / Enderecamento'											, ; //XA_DESCRIC
	'Dados Obito / Enderecamento'											, ; //XA_DESCSPA
	'Dados Obito / Enderecamento'											, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJV'																	, ; //XA_ALIAS
	'2'																		, ; //XA_ORDEM
	'Dados Contrato'														, ; //XA_DESCRIC
	'Dados Contrato'														, ; //XA_DESCSPA
	'Dados Contrato'														, ; //XA_DESCENG
	'A00'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJV'																	, ; //XA_ALIAS
	'2'																		, ; //XA_ORDEM
	'Servico Executado'														, ; //XA_DESCRIC
	'Servico Executado'														, ; //XA_DESCSPA
	'Servico Executado'														, ; //XA_DESCENG
	'A03'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJV'																	, ; //XA_ALIAS
	'3'																		, ; //XA_ORDEM
	'Pedido Venda'															, ; //XA_DESCRIC
	'Pedido Venda'															, ; //XA_DESCSPA
	'Pedido Venda'															, ; //XA_DESCENG
	''																		, ; //XA_AGRUP
	''																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJV'																	, ; //XA_ALIAS
	'3'																		, ; //XA_ORDEM
	'Autorizado'															, ; //XA_DESCRIC
	'Autorizado'															, ; //XA_DESCSPA
	'Autorizado'															, ; //XA_DESCENG
	'A01'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJV'																	, ; //XA_ALIAS
	'4'																		, ; //XA_ORDEM
	'Atendimento'															, ; //XA_DESCRIC
	'Atendimento'															, ; //XA_DESCSPA
	'Atendimento'															, ; //XA_DESCENG
	'A02'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJV'																	, ; //XA_ALIAS
	'5'																		, ; //XA_ORDEM
	'Tabela de Preco'														, ; //XA_DESCRIC
	'Tabela de Preco'														, ; //XA_DESCSPA
	'Tabela de Preco'														, ; //XA_DESCENG
	'A09'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJV'																	, ; //XA_ALIAS
	'6'																		, ; //XA_ORDEM
	'Observacao'															, ; //XA_DESCRIC
	'Observacao'															, ; //XA_DESCSPA
	'Observacao'															, ; //XA_DESCENG
	'A04'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJV'																	, ; //XA_ALIAS
	'7'																		, ; //XA_ORDEM
	'Dados Obito'															, ; //XA_DESCRIC
	'Dados Obito'															, ; //XA_DESCSPA
	'Dados Obito'															, ; //XA_DESCENG
	'A05'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJV'																	, ; //XA_ALIAS
	'8'																		, ; //XA_ORDEM
	'Dados Falecido'														, ; //XA_DESCRIC
	'Dados Falecido'														, ; //XA_DESCSPA
	'Dados Falecido'														, ; //XA_DESCENG
	'A06'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJV'																	, ; //XA_ALIAS
	'9'																		, ; //XA_ORDEM
	'Funeraria'																, ; //XA_DESCRIC
	'Funeraria'																, ; //XA_DESCSPA
	'Funeraria'																, ; //XA_DESCENG
	'A07'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJV'																	, ; //XA_ALIAS
	'A'																		, ; //XA_ORDEM
	'Endereco de Gaveta'													, ; //XA_DESCRIC
	'Endereco de Gaveta'													, ; //XA_DESCSPA
	'Endereco de Gaveta'													, ; //XA_DESCENG
	'JAZ'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJV'																	, ; //XA_ALIAS
	'B'																		, ; //XA_ORDEM
	'Endereco de Cremacao'													, ; //XA_DESCRIC
	'Endereco de Cremacao'													, ; //XA_DESCSPA
	'Endereco de Cremacao'													, ; //XA_DESCENG
	'CRE'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJV'																	, ; //XA_ALIAS
	'C'																		, ; //XA_ORDEM
	'Endereco Ossario'														, ; //XA_DESCRIC
	'Endereco Ossario'														, ; //XA_DESCSPA
	'Endereco Ossario'														, ; //XA_DESCENG
	'OSS'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

aAdd( aSXA, { ;
	'UJV'																	, ; //XA_ALIAS
	'D'																		, ; //XA_ORDEM
	'Status do Enderecamento'												, ; //XA_DESCRIC
	'Status do Enderecamento'												, ; //XA_DESCSPA
	'Status do Enderecamento'												, ; //XA_DESCENG
	'RES'																	, ; //XA_AGRUP
	'2'																		, ; //XA_TIPO
	'U'																		} ) //XA_PROPRI

nPosAgr := aScan( aEstrut, { |x| AllTrim( x ) == "XA_AGRUP" } )

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSXA ) )

dbSelectArea( "SXA" )
dbSetOrder( 1 )

For nI := 1 To Len( aSXA )

	If SXA->( dbSeek( aSXA[nI][1] + aSXA[nI][2] ) )

		lAlterou := .F.

		While !SXA->( EOF() ).AND.  SXA->( XA_ALIAS + XA_ORDEM ) == aSXA[nI][1] + aSXA[nI][2]

			If SXA->XA_AGRUP == aSXA[nI][nPosAgr]
				RecLock( "SXA", .F. )
				For nJ := 1 To Len( aSXA[nI] )
					If FieldPos( aEstrut[nJ] ) > 0 .AND. Alltrim(AllToChar(SXA->( FieldGet( nJ ) ))) <> Alltrim(AllToChar(aSXA[nI][nJ]))
						FieldPut( FieldPos( aEstrut[nJ] ), aSXA[nI][nJ] )
						lAlterou := .T.
					EndIf
				Next nJ
				dbCommit()
				MsUnLock()
			EndIf

			SXA->( dbSkip() )

		End

		If lAlterou
			AutoGrLog( "Foi alterada a pasta " + aSXA[nI][1] + "/" + aSXA[nI][2] + "  " + aSXA[nI][3] )
		EndIf

	Else

		RecLock( "SXA", .T. )
		For nJ := 1 To Len( aSXA[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSXA[nI][nJ] )
			EndIf
		Next nJ
		dbCommit()
		MsUnLock()

		AutoGrLog( "Foi incluída a pasta " + aSXA[nI][1] + "/" + aSXA[nI][2] + "  " + aSXA[nI][3] )

	EndIf

oProcess:IncRegua2( "Atualizando Arquivos (SXA)..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SXA" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSXB
Função de processamento da gravação do SXB - Consultas Padrao

@author TOTVS Protheus
@since  26/03/2020
@obs    Gerado por EXPORDIC - V.6.3.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSXB()
Local aEstrut   := {}
Local aSXB      := {}
Local cAlias    := ""
Local cMsg      := ""
Local lTodosNao := .F.
Local lTodosSim := .F.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0

AutoGrLog( "Ínicio da Atualização" + " SXB" + CRLF )

aEstrut := { "XB_ALIAS"  , "XB_TIPO"   , "XB_SEQ"    , "XB_COLUNA" , "XB_DESCRI" , "XB_DESCSPA", "XB_DESCENG", ;
             "XB_WCONTEM", "XB_CONTEM" }


//
// Consulta CTROEN
//
aAdd( aSXB, { ;
	'CTROEN'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'End Contrato Origem'													, ; //XB_DESCRI
	'End Contrato Origem'													, ; //XB_DESCSPA
	'End Contrato Origem'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U04'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CTROEN'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U_RCPGE016(M->U38_FILORI,M->U38_CTRORI)'								} ) //XB_CONTEM

aAdd( aSXB, { ;
	'CTROEN'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U_RCPGE16A()'															} ) //XB_CONTEM

//
// Consulta SRVTRD
//
aAdd( aSXB, { ;
	'SRVTRD'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'Servicos Ctr Destino'													, ; //XB_DESCRI
	'Servicos Ctr Destino'													, ; //XB_DESCSPA
	'Servicos Ctr Destino'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U37'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SRVTRD'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U_RCPGE015(M->U38_FILDES,M->U38_CTRDES)'								} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SRVTRD'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U_RCPGE15A()'															} ) //XB_CONTEM

//
// Consulta SRVTRO
//
aAdd( aSXB, { ;
	'SRVTRO'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'Srv Contrato Origem'													, ; //XB_DESCRI
	'Srv Contrato Origem'													, ; //XB_DESCSPA
	'Srv Contrato Origem'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U37'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SRVTRO'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U_RCPGE015(M->U38_FILORI,M->U38_CTRORI)'								} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SRVTRO'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U_RCPGE15A()'															} ) //XB_CONTEM

//
// Consulta STFUN
//
aAdd( aSXB, { ;
	'STFUN'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'Selecao Status Fun'													, ; //XB_DESCRI
	'Selecao Status Fun'													, ; //XB_DESCSPA
	'Selecao Status Fun'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UF2'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'STFUN'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U_STFUN()'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'STFUN'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'&(ReadVar())'															} ) //XB_CONTEM

//
// Consulta SX3IMP
//
aAdd( aSXB, { ;
	'SX3IMP'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'Campos Importacao'														, ; //XB_DESCRI
	'Campos Importacao'														, ; //XB_DESCSPA
	'Campos Importacao'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UH9'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SX3IMP'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U_UCONSX3("UH8","UH8MASTER","UH8_ROTINA")'								} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SX3IMP'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U_USX3RET(1)'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SX3IMP'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U_USX3RET(2)'															} ) //XB_CONTEM

//
// Consulta SX3MOD
//
aAdd( aSXB, { ;
	'SX3MOD'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'Campos'																, ; //XB_DESCRI
	'Campos'																, ; //XB_DESCSPA
	'Campos'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJK'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SX3MOD'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U_UCONSX3("UJK","UJKDETAIL","UJK_TABELA")'								} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SX3MOD'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U_USX3RET(1)'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'SX3MOD'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U_USX3RET(2)'															} ) //XB_CONTEM

//
// Consulta U00
//
aAdd( aSXB, { ;
	'U00'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Contrato CPG'															, ; //XB_DESCRI
	'Contrato CPG'															, ; //XB_DESCSPA
	'Contrato CPG'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U00'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U00'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U00'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Cnpj/Cpf'																, ; //XB_DESCRI
	'Cnpj/Cpf'																, ; //XB_DESCSPA
	'Cnpj/Cpf'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U00'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U00_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U00'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Data'																	, ; //XB_DESCRI
	'Data'																	, ; //XB_DESCSPA
	'Data'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U00_DATA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U00'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Cliente'																, ; //XB_DESCRI
	'Cliente'																, ; //XB_DESCSPA
	'Cliente'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U00_CLIENT'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U00'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Nome cliente'															, ; //XB_DESCRI
	'Nome cliente'															, ; //XB_DESCSPA
	'Nome cliente'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U00_NOMCLI'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U00'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'CNPJ/CPF'																, ; //XB_DESCRI
	'CNPJ/CPF'																, ; //XB_DESCSPA
	'CNPJ/CPF'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U00_CGC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U00'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Data'																	, ; //XB_DESCRI
	'Data'																	, ; //XB_DESCSPA
	'Data'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U00_DATA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U00'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Cliente'																, ; //XB_DESCRI
	'Cliente'																, ; //XB_DESCSPA
	'Cliente'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U00_CLIENT'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U00'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Nome cliente'															, ; //XB_DESCRI
	'Nome cliente'															, ; //XB_DESCSPA
	'Nome cliente'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U00_NOMCLI'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U00'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U00->U00_CODIGO'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U00'																	, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	"U00->U00_STATUS $ 'A/S'"												} ) //XB_CONTEM

//
// Consulta U00ACF
//
aAdd( aSXB, { ;
	'U00ACF'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Contrato para ACF'														, ; //XB_DESCRI
	'Contrato para ACF'														, ; //XB_DESCSPA
	'Contrato para ACF'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U00'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U00ACF'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U00ACF'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U00_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U00ACF'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Data'																	, ; //XB_DESCRI
	'Data'																	, ; //XB_DESCSPA
	'Data'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U00_DATA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U00ACF'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Plano'																	, ; //XB_DESCRI
	'Plano'																	, ; //XB_DESCSPA
	'Plano'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U00_PLANO'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U00ACF'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Desc. plano'															, ; //XB_DESCRI
	'Desc. plano'															, ; //XB_DESCSPA
	'Desc. plano'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U00_DESCPL'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U00ACF'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Status'																, ; //XB_DESCRI
	'Status'																, ; //XB_DESCSPA
	'Status'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U00_STATUS'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U00ACF'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U00->U00_CODIGO'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U00ACF'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U00->U00_FILIAL = xFilial("U00") .And. U00->U00_CLIENT = M->ACF_CLIENT'	} ) //XB_CONTEM

//
// Consulta U00LST
//
aAdd( aSXB, { ;
	'U00LST'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'Planos Cemiterio Cob'													, ; //XB_DESCRI
	'Planos Cemiterio Cob'													, ; //XB_DESCSPA
	'Planos Cemiterio Cob'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U00'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U00LST'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U_RTMK10CC()'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U00LST'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'&(ReadVar())'															} ) //XB_CONTEM

//
// Consulta U00TRF
//
aAdd( aSXB, { ;
	'U00TRF'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Contratos Destino'														, ; //XB_DESCRI
	'Contratos Destino'														, ; //XB_DESCSPA
	'Contratos Destino'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U00'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U00TRF'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U00TRF'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Nome Cliente'															, ; //XB_DESCRI
	'Nome Cliente'															, ; //XB_DESCSPA
	'Nome Cliente'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U00TRF'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U00_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U00TRF'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Data'																	, ; //XB_DESCRI
	'Data'																	, ; //XB_DESCSPA
	'Data'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U00_DATA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U00TRF'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Cliente'																, ; //XB_DESCRI
	'Cliente'																, ; //XB_DESCSPA
	'Cliente'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U00_CLIENT'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U00TRF'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Loja'																	, ; //XB_DESCSPA
	'Loja'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U00_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U00TRF'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Nome cliente'															, ; //XB_DESCRI
	'Nome cliente'															, ; //XB_DESCSPA
	'Nome cliente'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U00_NOMCLI'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U00TRF'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U00_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U00TRF'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Data'																	, ; //XB_DESCRI
	'Data'																	, ; //XB_DESCSPA
	'Data'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U00_DATA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U00TRF'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Cliente'																, ; //XB_DESCRI
	'Cliente'																, ; //XB_DESCSPA
	'Cliente'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U00_CLIENT'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U00TRF'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Loja'																	, ; //XB_DESCSPA
	'Loja'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U00_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U00TRF'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Nome cliente'															, ; //XB_DESCRI
	'Nome cliente'															, ; //XB_DESCSPA
	'Nome cliente'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U00_NOMCLI'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U00TRF'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U00->U00_CODIGO'														} ) //XB_CONTEM

//
// Consulta U02
//
aAdd( aSXB, { ;
	'U02'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Autorizado'															, ; //XB_DESCRI
	'Autorizado'															, ; //XB_DESCSPA
	'Autorizado'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U02'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U02'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo+item'															, ; //XB_DESCRI
	'Codigo+item'															, ; //XB_DESCSPA
	'Codigo+item'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U02'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Filial'																, ; //XB_DESCRI
	'Sucursal'																, ; //XB_DESCSPA
	'Branch'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U02_FILIAL'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U02'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U02_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U02'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Item'																	, ; //XB_DESCRI
	'Item'																	, ; //XB_DESCSPA
	'Item'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U02_ITEM'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U02'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nome'																	, ; //XB_DESCSPA
	'Nome'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U02_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U02'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U02->U02_ITEM'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U02'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U02->U02_NOME'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U02'																	, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U02->U02_CODIGO==@#U_RETCONTR()'										} ) //XB_CONTEM

//
// Consulta U05
//
aAdd( aSXB, { ;
	'U05'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Tipos de Plano'														, ; //XB_DESCRI
	'.'																		, ; //XB_DESCSPA
	'.'																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U05'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U05'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U05'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U05'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U05'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Filial'																, ; //XB_DESCRI
	'Sucursal'																, ; //XB_DESCSPA
	'Branch'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U05_FILIAL'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U05'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U05_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U05'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U05_DESCRI'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U05'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Filial'																, ; //XB_DESCRI
	'Sucursal'																, ; //XB_DESCSPA
	'Branch'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U05_FILIAL'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U05'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U05_DESCRI'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U05'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U05_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U05'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U05->U05_CODIGO'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U05'																	, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U05->U05_SITUAC == "A"'												} ) //XB_CONTEM

//
// Consulta U05MRK
//
aAdd( aSXB, { ;
	'U05MRK'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'Planos multi selecao'													, ; //XB_DESCRI
	'Planos multi selecao'													, ; //XB_DESCSPA
	'Planos multi selecao'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U05'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U05MRK'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U_RCPGA018()'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U05MRK'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'&(ReadVar())'															} ) //XB_CONTEM

//
// Consulta U08
//
aAdd( aSXB, { ;
	'U08'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Cadastro de quadras'													, ; //XB_DESCRI
	'Cadastro de quadras'													, ; //XB_DESCSPA
	'Cadastro de quadras'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U08'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U08'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Quadra'																, ; //XB_DESCRI
	'Quadra'																, ; //XB_DESCSPA
	'Quadra'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U08'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Quadra'																, ; //XB_DESCRI
	'Quadra'																, ; //XB_DESCSPA
	'Quadra'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U08_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U08'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U08_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U08'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U08->U08_CODIGO'														} ) //XB_CONTEM

//
// Consulta U08CTD
//
aAdd( aSXB, { ;
	'U08CTD'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Quadras Ctr Destino'													, ; //XB_DESCRI
	'Quadras Ctr Destino'													, ; //XB_DESCSPA
	'Quadras Ctr Destino'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U08'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U08CTD'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Quadra'																, ; //XB_DESCRI
	'Quadra'																, ; //XB_DESCSPA
	'Quadra'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U08CTD'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Quadra'																, ; //XB_DESCRI
	'Quadra'																, ; //XB_DESCSPA
	'Quadra'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U08_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U08CTD'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U08_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U08CTD'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U08->U08_CODIGO'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U08CTD'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'@#U_UQdCtDes()'														} ) //XB_CONTEM

//
// Consulta U09
//
aAdd( aSXB, { ;
	'U09'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Cadastro Módulo'														, ; //XB_DESCRI
	'Cadastro Módulo'														, ; //XB_DESCSPA
	'Cadastro Módulo'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U09'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U09'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Quadra+modulo'															, ; //XB_DESCRI
	'Quadra+modulo'															, ; //XB_DESCSPA
	'Quadra+modulo'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U09'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Filial'																, ; //XB_DESCRI
	'Sucursal'																, ; //XB_DESCSPA
	'Branch'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U09_FILIAL'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U09'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Quadra'																, ; //XB_DESCRI
	'Quadra'																, ; //XB_DESCSPA
	'Quadra'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U09_QUADRA'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U09'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Modulo'																, ; //XB_DESCRI
	'Modulo'																, ; //XB_DESCSPA
	'Modulo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U09_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U09'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Ativo?'																, ; //XB_DESCRI
	'Ativo?'																, ; //XB_DESCSPA
	'Ativo?'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U09_STATUS'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U09'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U09_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U09'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U09->U09_CODIGO'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U09'																	, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U09->U09_FILIAL = xFilial("U09")'										} ) //XB_CONTEM

//
// Consulta U09CTD
//
aAdd( aSXB, { ;
	'U09CTD'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Modulo Ctr Destino'													, ; //XB_DESCRI
	'Modulo Ctr Destino'													, ; //XB_DESCSPA
	'Modulo Ctr Destino'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U09'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U09CTD'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Quadra+modulo'															, ; //XB_DESCRI
	'Quadra+modulo'															, ; //XB_DESCSPA
	'Quadra+modulo'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U09CTD'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Quadra'																, ; //XB_DESCRI
	'Quadra'																, ; //XB_DESCSPA
	'Quadra'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U09_QUADRA'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U09CTD'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Modulo'																, ; //XB_DESCRI
	'Modulo'																, ; //XB_DESCSPA
	'Modulo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U09_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U09CTD'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U09_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U09CTD'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U09->U09_CODIGO'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U09CTD'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'@#U_UModCtDes()'														} ) //XB_CONTEM

//
// Consulta U09U04
//
aAdd( aSXB, { ;
	'U09U04'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Modulos'																, ; //XB_DESCRI
	'Modulos'																, ; //XB_DESCSPA
	'Modulos'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U09'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U09U04'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Quadra+modulo'															, ; //XB_DESCRI
	'Quadra+modulo'															, ; //XB_DESCSPA
	'Quadra+modulo'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U09U04'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Filial'																, ; //XB_DESCRI
	'Sucursal'																, ; //XB_DESCSPA
	'Branch'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U09_FILIAL'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U09U04'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Quadra'																, ; //XB_DESCRI
	'Quadra'																, ; //XB_DESCSPA
	'Quadra'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U09_QUADRA'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U09U04'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Modulo'																, ; //XB_DESCRI
	'Modulo'																, ; //XB_DESCSPA
	'Modulo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U09_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U09U04'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U09_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U09U04'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U09->U09_CODIGO'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U09U04'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U09->U09_STATUS == "S" .And. U09->U09_QUADRA == U_RETQD()'				} ) //XB_CONTEM

//
// Consulta U09U25
//
aAdd( aSXB, { ;
	'U09U25'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Modulos'																, ; //XB_DESCRI
	'Modulos'																, ; //XB_DESCSPA
	'Modulos'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U09'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U09U25'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Quadra+modulo'															, ; //XB_DESCRI
	'Quadra+modulo'															, ; //XB_DESCSPA
	'Quadra+modulo'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U09U25'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Filial'																, ; //XB_DESCRI
	'Sucursal'																, ; //XB_DESCSPA
	'Branch'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U09_FILIAL'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U09U25'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Quadra'																, ; //XB_DESCRI
	'Quadra'																, ; //XB_DESCSPA
	'Quadra'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U09_QUADRA'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U09U25'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Modulo'																, ; //XB_DESCRI
	'Modulo'																, ; //XB_DESCSPA
	'Modulo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U09_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U09U25'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U09_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U09U25'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U09->U09_CODIGO'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U09U25'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U09->U09_STATUS == "S" .And. U09->U09_QUADRA == M->U25_QUADRA'			} ) //XB_CONTEM

//
// Consulta U10CTD
//
aAdd( aSXB, { ;
	'U10CTD'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Jazigo Ctr Destino'													, ; //XB_DESCRI
	'Jazigo Ctr Destino'													, ; //XB_DESCSPA
	'Jazigo Ctr Destino'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U10'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U10CTD'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Quadra+modulo+jazigo'													, ; //XB_DESCRI
	'Quadra+modulo+jazigo'													, ; //XB_DESCSPA
	'Quadra+modulo+jazigo'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U10CTD'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Jazigo'																, ; //XB_DESCRI
	'Jazigo'																, ; //XB_DESCSPA
	'Jazigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U10_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U10CTD'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U10_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U10CTD'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U10->U10_CODIGO'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U10CTD'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'@#U_UJazCtDes()'														} ) //XB_CONTEM

//
// Consulta U10U04
//
aAdd( aSXB, { ;
	'U10U04'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'JAZIGO'																, ; //XB_DESCRI
	'JAZIGO'																, ; //XB_DESCSPA
	'JAZIGO'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U10'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U10U04'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Quadra+modulo+jazigo'													, ; //XB_DESCRI
	'Quadra+modulo+jazigo'													, ; //XB_DESCSPA
	'Quadra+modulo+jazigo'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U10U04'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Filial'																, ; //XB_DESCRI
	'Sucursal'																, ; //XB_DESCSPA
	'Branch'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U10_FILIAL'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U10U04'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Quadra'																, ; //XB_DESCRI
	'Quadra'																, ; //XB_DESCSPA
	'Quadra'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U10_QUADRA'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U10U04'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Modulo'																, ; //XB_DESCRI
	'Modulo'																, ; //XB_DESCSPA
	'Modulo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U10_MODULO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U10U04'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Jazigo'																, ; //XB_DESCRI
	'Jazigo'																, ; //XB_DESCSPA
	'Jazigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U10_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U10U04'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U10_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U10U04'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U10->U10_CODIGO'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U10U04'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U10->U10_STATUS == "S" .And. U10->U10_QUADRA == U_RETQD() .And. U10->U10_MODULO == U_RETMD()'} ) //XB_CONTEM

//
// Consulta U10U25
//
aAdd( aSXB, { ;
	'U10U25'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'JAZIGO'																, ; //XB_DESCRI
	'JAZIGO'																, ; //XB_DESCSPA
	'JAZIGO'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U10'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U10U25'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Quadra+modulo+jazigo'													, ; //XB_DESCRI
	'Quadra+modulo+jazigo'													, ; //XB_DESCSPA
	'Quadra+modulo+jazigo'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U10U25'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Filial'																, ; //XB_DESCRI
	'Sucursal'																, ; //XB_DESCSPA
	'Branch'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U10_FILIAL'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U10U25'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Quadra'																, ; //XB_DESCRI
	'Quadra'																, ; //XB_DESCSPA
	'Quadra'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U10_QUADRA'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U10U25'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Modulo'																, ; //XB_DESCRI
	'Modulo'																, ; //XB_DESCSPA
	'Modulo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U10_MODULO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U10U25'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Jazigo'																, ; //XB_DESCRI
	'Jazigo'																, ; //XB_DESCSPA
	'Jazigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U10_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U10U25'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U10_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U10U25'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U10->U10_CODIGO'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U10U25'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U10->U10_STATUS == "S" .And. U10->U10_QUADRA == M->U25_QUADRA .And. U10->U10_MODULO == M->U25_MODULO'} ) //XB_CONTEM

//
// Consulta U11
//
aAdd( aSXB, { ;
	'U11'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Cadastro Crematorio'													, ; //XB_DESCRI
	'Cadastro Crematorio'													, ; //XB_DESCSPA
	'Cadastro Crematorio'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U11'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U11'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Crematorio'															, ; //XB_DESCRI
	'Crematorio'															, ; //XB_DESCSPA
	'Crematorio'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U11'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Crematorio'															, ; //XB_DESCRI
	'Crematorio'															, ; //XB_DESCSPA
	'Crematorio'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U11_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U11'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U11_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U11'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U11->U11_CODIGO'														} ) //XB_CONTEM

//
// Consulta U11CTD
//
aAdd( aSXB, { ;
	'U11CTD'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Crematorio Ctr Dest.'													, ; //XB_DESCRI
	'Crematorio Ctr Dest.'													, ; //XB_DESCSPA
	'Crematorio Ctr Dest.'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U11'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U11CTD'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Crematorio'															, ; //XB_DESCRI
	'Crematorio'															, ; //XB_DESCSPA
	'Crematorio'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U11CTD'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Crematorio'															, ; //XB_DESCRI
	'Crematorio'															, ; //XB_DESCSPA
	'Crematorio'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U11_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U11CTD'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U11_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U11CTD'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U11->U11_CODIGO'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U11CTD'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'@#U_UCremCtDes()'														} ) //XB_CONTEM

//
// Consulta U12CTD
//
aAdd( aSXB, { ;
	'U12CTD'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Nicho Columb. Ctr De'													, ; //XB_DESCRI
	'Nicho Columb. Ctr De'													, ; //XB_DESCSPA
	'Nicho Columb. Ctr De'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U12'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U12CTD'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Crematorio+nicho'														, ; //XB_DESCRI
	'Crematorio+nicho'														, ; //XB_DESCSPA
	'Crematorio+nicho'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U12CTD'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Nicho'																	, ; //XB_DESCRI
	'Nicho'																	, ; //XB_DESCSPA
	'Nicho'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U12_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U12CTD'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U12_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U12CTD'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U12->U12_CODIGO'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U12CTD'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'@#U_UNichCoCtDes()'													} ) //XB_CONTEM

//
// Consulta U12U04
//
aAdd( aSXB, { ;
	'U12U04'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Nicho columbario'														, ; //XB_DESCRI
	'Nicho columbario'														, ; //XB_DESCSPA
	'Nicho columbario'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U12'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U12U04'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Crematorio+nicho'														, ; //XB_DESCRI
	'Crematorio+nicho'														, ; //XB_DESCSPA
	'Crematorio+nicho'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U12U04'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Filial'																, ; //XB_DESCRI
	'Sucursal'																, ; //XB_DESCSPA
	'Branch'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U12_FILIAL'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U12U04'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Crematorio'															, ; //XB_DESCRI
	'Crematorio'															, ; //XB_DESCSPA
	'Crematorio'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U12_CREMAT'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U12U04'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nicho'																	, ; //XB_DESCRI
	'Nicho'																	, ; //XB_DESCSPA
	'Nicho'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U12_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U12U04'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U12_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U12U04'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U12->U12_CODIGO'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U12U04'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U12->U12_STATUS == "S" .And. U12->U12_CREMAT  == U_RETCREMA()'			} ) //XB_CONTEM

//
// Consulta U13
//
aAdd( aSXB, { ;
	'U13'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Cadastro Ossario'														, ; //XB_DESCRI
	'Cadastro Ossario'														, ; //XB_DESCSPA
	'Cadastro Ossario'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U13'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U13'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Ossario'																, ; //XB_DESCRI
	'Ossario'																, ; //XB_DESCSPA
	'Ossario'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U13'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Ossario'																, ; //XB_DESCRI
	'Ossario'																, ; //XB_DESCSPA
	'Ossario'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U13_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U13'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U13_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U13'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U13->U13_CODIGO'														} ) //XB_CONTEM

//
// Consulta U13CTD
//
aAdd( aSXB, { ;
	'U13CTD'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Ossario Ctr Destino'													, ; //XB_DESCRI
	'Ossario Ctr Destino'													, ; //XB_DESCSPA
	'Ossario Ctr Destino'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U13'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U13CTD'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Ossario'																, ; //XB_DESCRI
	'Ossario'																, ; //XB_DESCSPA
	'Ossario'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U13CTD'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Ossario'																, ; //XB_DESCRI
	'Ossario'																, ; //XB_DESCSPA
	'Ossario'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U13_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U13CTD'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U13_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U13CTD'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U13->U13_CODIGO'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U13CTD'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'@#U_UOssariCtDes()'													} ) //XB_CONTEM

//
// Consulta U14CTD
//
aAdd( aSXB, { ;
	'U14CTD'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Nicho Ossario Ctr De'													, ; //XB_DESCRI
	'Nicho Ossario Ctr De'													, ; //XB_DESCSPA
	'Nicho Ossario Ctr De'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U14'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U14CTD'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Ossario+nicho'															, ; //XB_DESCRI
	'Ossario+nicho'															, ; //XB_DESCSPA
	'Ossario+nicho'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U14CTD'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Nicho'																	, ; //XB_DESCRI
	'Nicho'																	, ; //XB_DESCSPA
	'Nicho'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U14_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U14CTD'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U14_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U14CTD'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U14->U14_CODIGO'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U14CTD'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'@#U_UNichoOsCtDes()'													} ) //XB_CONTEM

//
// Consulta U14U04
//
aAdd( aSXB, { ;
	'U14U04'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Nicho ossario'															, ; //XB_DESCRI
	'Nicho ossario'															, ; //XB_DESCSPA
	'Nicho ossario'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U14'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U14U04'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Ossario+nicho'															, ; //XB_DESCRI
	'Ossario+nicho'															, ; //XB_DESCSPA
	'Ossario+nicho'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U14U04'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Filial'																, ; //XB_DESCRI
	'Sucursal'																, ; //XB_DESCSPA
	'Branch'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U14_FILIAL'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U14U04'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Ossario'																, ; //XB_DESCRI
	'Ossario'																, ; //XB_DESCSPA
	'Ossario'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U14_OSSARI'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U14U04'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nicho'																	, ; //XB_DESCRI
	'Nicho'																	, ; //XB_DESCSPA
	'Nicho'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U14_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U14U04'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U14_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U14U04'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U14->U14_CODIGO'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U14U04'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U14->U14_STATUS == "S" .And. U14->U14_OSSARI == U_RETOSSA()'			} ) //XB_CONTEM

//
// Consulta U15
//
aAdd( aSXB, { ;
	'U15'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Categoria Comissao'													, ; //XB_DESCRI
	'Categoria Comissao'													, ; //XB_DESCSPA
	'Categoria Comissao'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U15'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U15'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U15'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U15_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U15'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U15_DESCRI'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U15'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'% ou Valor'															, ; //XB_DESCRI
	'% ou Valor'															, ; //XB_DESCSPA
	'% ou Valor'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U15_TPVAL'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U15'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'% ou Vlr Pro'															, ; //XB_DESCRI
	'% ou Vlr Pro'															, ; //XB_DESCSPA
	'% ou Vlr Pro'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U15_PRIOR'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U15'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'% Perc.'																, ; //XB_DESCRI
	'% Perc.'																, ; //XB_DESCSPA
	'% Perc.'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U15_PERC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U15'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'06'																	, ; //XB_COLUNA
	'Valor'																	, ; //XB_DESCRI
	'Valor'																	, ; //XB_DESCSPA
	'Valor'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U15_VAL'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U15'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U15->U15_CODIGO'														} ) //XB_CONTEM

//
// Consulta U18
//
aAdd( aSXB, { ;
	'U18'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Ciclo Pgto Comissao'													, ; //XB_DESCRI
	'Ciclo Pgto Comissao'													, ; //XB_DESCSPA
	'Ciclo Pgto Comissao'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U18'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U18'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U18'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U18_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U18'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U18_DESCRI'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U18'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Dia do Fech.'															, ; //XB_DESCRI
	'Dia do Fech.'															, ; //XB_DESCSPA
	'Dia do Fech.'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U18_DIAFEC'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U18'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U18->U18_CODIGO'														} ) //XB_CONTEM

//
// Consulta U22
//
aAdd( aSXB, { ;
	'U22'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Indices'																, ; //XB_DESCRI
	'Indices'																, ; //XB_DESCSPA
	'Indices'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U22'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U22'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U22'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U22'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U22_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U22'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U22_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U22'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U22_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U22'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U22_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U22'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U22->U22_CODIGO'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U22'																	, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	"U22->U22_STATUS == 'A'"												} ) //XB_CONTEM

//
// Consulta U24
//
aAdd( aSXB, { ;
	'U24'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'SALAS DE LOCACAO'														, ; //XB_DESCRI
	'.'																		, ; //XB_DESCSPA
	'.'																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U24'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U24'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U24'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U24'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U24'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Filial'																, ; //XB_DESCRI
	'Sucursal'																, ; //XB_DESCSPA
	'Branch'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U24_FILIAL'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U24'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U24_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U24'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U24_DESCRI'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U24'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Filial'																, ; //XB_DESCRI
	'Sucursal'																, ; //XB_DESCSPA
	'Branch'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U24_FILIAL'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U24'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U24_DESCRI'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U24'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U24_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U24'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U24->U24_CODIGO'														} ) //XB_CONTEM

//
// Consulta U31
//
aAdd( aSXB, { ;
	'U31'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Motivos Cancelamento'													, ; //XB_DESCRI
	'Motivos Cancelamento'													, ; //XB_DESCSPA
	'Motivos Cancelamento'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U31'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U31'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U31'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U31'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U31'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Filial'																, ; //XB_DESCRI
	'Sucursal'																, ; //XB_DESCSPA
	'Branch'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U31_FILIAL'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U31'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U31_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U31'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U31_DESCRI'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U31'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Filial'																, ; //XB_DESCRI
	'Sucursal'																, ; //XB_DESCSPA
	'Branch'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U31_FILIAL'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U31'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U31_DESCRI'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U31'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U31_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U31'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U31->U31_CODIGO'														} ) //XB_CONTEM

//
// Consulta U34
//
aAdd( aSXB, { ;
	'U34'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Consulta Regiões'														, ; //XB_DESCRI
	'Consulta Regiões'														, ; //XB_DESCSPA
	'Consulta Regiões'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U34'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U34'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Código + Rota + Stat'													, ; //XB_DESCRI
	'Código + Rota + Stat'													, ; //XB_DESCSPA
	'Código + Rota + Stat'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U34'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo Rota'															, ; //XB_DESCRI
	'Codigo Rota'															, ; //XB_DESCSPA
	'Codigo Rota'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U34_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U34'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Rota'																	, ; //XB_DESCRI
	'Rota'																	, ; //XB_DESCSPA
	'Rota'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U34_DESCRI'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U34'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Status'																, ; //XB_DESCRI
	'Status'																, ; //XB_DESCSPA
	'Status'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U34_STATUS'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U34'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U34->U34_CODIGO'														} ) //XB_CONTEM

//
// Consulta U34MAR
//
aAdd( aSXB, { ;
	'U34MAR'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'Consulta Rotas'														, ; //XB_DESCRI
	'Consulta Rotas'														, ; //XB_DESCSPA
	'Consulta Rotas'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U34'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U34MAR'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U_RUTIL004()'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U34MAR'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'&(ReadVar())'															} ) //XB_CONTEM

//
// Consulta U34MRK
//
aAdd( aSXB, { ;
	'U34MRK'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'Região multi seleção'													, ; //XB_DESCRI
	'Região multi seleção'													, ; //XB_DESCSPA
	'Região multi seleção'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U34'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U34MRK'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U_RFINR003()'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U34MRK'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'&(ReadVar())'															} ) //XB_CONTEM

//
// Consulta U37
//
aAdd( aSXB, { ;
	'U37'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Servicos Habilitados'													, ; //XB_DESCRI
	'Servicos Habilitados'													, ; //XB_DESCSPA
	'Servicos Habilitados'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U37'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U37'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Codigo+servico'														, ; //XB_DESCRI
	'Codigo+servico'														, ; //XB_DESCSPA
	'Codigo+servico'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U37'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Servico'																, ; //XB_DESCRI
	'Servico'																, ; //XB_DESCSPA
	'Servico'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U37_SERVIC'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U37'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U37_DESCRI'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U37'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U37->U37_SERVIC'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U37'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U37->U37_DESCRI'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U37'																	, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U37->U37_CODIGO ==  @#M->UJV_CONTRA'									} ) //XB_CONTEM

//
// Consulta U37TRF
//
aAdd( aSXB, { ;
	'U37TRF'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Consulta Servico'														, ; //XB_DESCRI
	'Consulta Servico'														, ; //XB_DESCSPA
	'Consulta Servico'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U37'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U37TRF'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Codigo+servico'														, ; //XB_DESCRI
	'Codigo+servico'														, ; //XB_DESCSPA
	'Codigo+servico'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U37TRF'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U37_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U37TRF'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Servico'																, ; //XB_DESCRI
	'Servico'																, ; //XB_DESCSPA
	'Servico'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U37_SERVIC'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U37TRF'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U37->U37_CODIGO'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U37TRF'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U37->U37_DESCRI'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U37TRF'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U37->U37_CODIGO ==  @#M->U38_CTRORI'									} ) //XB_CONTEM

//
// Consulta U60
//
aAdd( aSXB, { ;
	'U60'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Metodo Pagamento'														, ; //XB_DESCRI
	'Metodo Pagamento'														, ; //XB_DESCSPA
	'Metodo Pagamento'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U60'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U60'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Forma Pgto'															, ; //XB_DESCRI
	'Forma Pgto'															, ; //XB_DESCSPA
	'Forma Pgto'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U60'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Forma Pgto'															, ; //XB_DESCRI
	'Forma Pgto'															, ; //XB_DESCSPA
	'Forma Pgto'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U60_FORPG'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U60'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Codigo Vindi'															, ; //XB_DESCRI
	'Codigo Vindi'															, ; //XB_DESCSPA
	'Codigo Vindi'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U60_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U60'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U60->U60_FORPG'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U60'																	, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U60->U60_STATUS == "A"'												} ) //XB_CONTEM

//
// Consulta U67
//
aAdd( aSXB, { ;
	'U67'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Bandeiras Vindi'														, ; //XB_DESCRI
	'Bandeiras Vindi'														, ; //XB_DESCSPA
	'Bandeiras Vindi'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U67'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U67'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U67'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U67_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U67'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U67_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U67'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U67->U67_CODIGO'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'U67'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U67->U67_DESC'															} ) //XB_CONTEM

//
// Consulta UF0
//
aAdd( aSXB, { ;
	'UF0'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Plano funerario'														, ; //XB_DESCRI
	'Plano funerario'														, ; //XB_DESCSPA
	'Plano funerario'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UF0'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF0'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF0'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF0'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UF0_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF0'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UF0_DESCRI'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF0'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UF0_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF0'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UF0_DESCRI'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF0'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UF0->UF0_CODIGO'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF0'																	, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UF0->UF0_STATUS == "A"'												} ) //XB_CONTEM

//
// Consulta UF0LST
//
aAdd( aSXB, { ;
	'UF0LST'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'Planos List Cob'														, ; //XB_DESCRI
	'Planos List Cob'														, ; //XB_DESCSPA
	'Planos List Cob'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UF0'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF0LST'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U_RTMK10CF()'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF0LST'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'&(ReadVar())'															} ) //XB_CONTEM

//
// Consulta UF0MRK
//
aAdd( aSXB, { ;
	'UF0MRK'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'Planos multi selecao'													, ; //XB_DESCRI
	'Planos multi selecao'													, ; //XB_DESCSPA
	'Planos multi selecao'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UF0'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF0MRK'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U_RFUNA013()'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF0MRK'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'&(ReadVar())'															} ) //XB_CONTEM

//
// Consulta UF2
//
aAdd( aSXB, { ;
	'UF2'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Contrato Funeraria'													, ; //XB_DESCRI
	'Contrato Funeraria'													, ; //XB_DESCSPA
	'Contrato Funeraria'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UF2'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF2'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UF2_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Cliente'																, ; //XB_DESCRI
	'Cliente'																, ; //XB_DESCSPA
	'Cliente'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UF2_CLIENT'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Loja'																	, ; //XB_DESCRI
	'Loja'																	, ; //XB_DESCSPA
	'Loja'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UF2_LOJA'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Nome Cliente'															, ; //XB_DESCRI
	'Nome Cliente'															, ; //XB_DESCSPA
	'Nome Cliente'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'Posicione("SA1",1,xFilial("SA1")+UF2->UF2_CLIENT+UF2->UF2_LOJA,"A1_NOME")'	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'05'																	, ; //XB_COLUNA
	'Dt Cadastro'															, ; //XB_DESCRI
	'Dt Cadastro'															, ; //XB_DESCSPA
	'Dt Cadastro'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UF2_DTCAD'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF2'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UF2->UF2_CODIGO'														} ) //XB_CONTEM

//
// Consulta UF2ESP
//
aAdd( aSXB, { ;
	'UF2ESP'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'Contratos especifica'													, ; //XB_DESCRI
	'Contratos especifica'													, ; //XB_DESCSPA
	'Contratos especifica'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UF2'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF2ESP'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U_RFUNA021()'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF2ESP'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U_FUNA021RET()'														} ) //XB_CONTEM

//
// Consulta UF2MRK
//
aAdd( aSXB, { ;
	'UF2MRK'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'MultiSeleção Funerar'													, ; //XB_DESCRI
	'MultiSeleção Funerar'													, ; //XB_DESCSPA
	'MultiSeleção Funerar'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UF2'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF2MRK'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U_RFUNR002()'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF2MRK'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'&(ReadVar())'															} ) //XB_CONTEM

//
// Consulta UF4
//
aAdd( aSXB, { ;
	'UF4'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Beneficiarios'															, ; //XB_DESCRI
	'Beneficiarios'															, ; //XB_DESCSPA
	'Beneficiarios'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UF4'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF4'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Contrato+item'															, ; //XB_DESCRI
	'Contrato+item'															, ; //XB_DESCSPA
	'Contrato+item'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF4'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Filial'																, ; //XB_DESCRI
	'Sucursal'																, ; //XB_DESCSPA
	'Branch'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UF4_FILIAL'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF4'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nome'																	, ; //XB_DESCSPA
	'Nome'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UF4_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF4'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UF4->UF4_ITEM'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF4'																	, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UF4->UF4_CODIGO==@#U_CONTRF()'											} ) //XB_CONTEM

//
// Consulta UF42
//
aAdd( aSXB, { ;
	'UF42'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Beneficiarios'															, ; //XB_DESCRI
	'Beneficiarios'															, ; //XB_DESCSPA
	'Beneficiarios'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UF4'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF42'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Contrato+item'															, ; //XB_DESCRI
	'Contrato+item'															, ; //XB_DESCSPA
	'Contrato+item'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF42'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Filial'																, ; //XB_DESCRI
	'Sucursal'																, ; //XB_DESCSPA
	'Branch'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UF4_FILIAL'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF42'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nome'																	, ; //XB_DESCSPA
	'Nome'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UF4_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF42'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UF4->UF4_ITEM'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF42'																	, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UF4->UF4_CODIGO==@#U_CONTRJ()'											} ) //XB_CONTEM

//
// Consulta UF4CON
//
aAdd( aSXB, { ;
	'UF4CON'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Benef.Convalescencia'													, ; //XB_DESCRI
	'Benef.Convalescencia'													, ; //XB_DESCSPA
	'Benef.Convalescencia'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UF4'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF4CON'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Contrato+item'															, ; //XB_DESCRI
	'Contrato+item'															, ; //XB_DESCSPA
	'Contrato+item'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF4CON'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Item'																	, ; //XB_DESCRI
	'Item'																	, ; //XB_DESCSPA
	'Item'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UF4_ITEM'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF4CON'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nome'																	, ; //XB_DESCSPA
	'Nome'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UF4_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF4CON'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UF4->UF4_ITEM'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF4CON'																, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UF4->UF4_CODIGO == @#M->UJH_CONTRA'									} ) //XB_CONTEM

//
// Consulta UF6
//
aAdd( aSXB, { ;
	'UF6'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Motoristas'															, ; //XB_DESCRI
	'Motoristas'															, ; //XB_DESCSPA
	'Motoristas'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UF6'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF6'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF6'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Cpf'																	, ; //XB_DESCRI
	'Cpf'																	, ; //XB_DESCSPA
	'Cpf'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF6'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nome'																	, ; //XB_DESCSPA
	'Nome'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF6'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF6'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Filial'																, ; //XB_DESCRI
	'Sucursal'																, ; //XB_DESCSPA
	'Branch'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UF6_FILIAL'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF6'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UF6_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF6'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'CPF'																	, ; //XB_DESCRI
	'CPF'																	, ; //XB_DESCSPA
	'CPF'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UF6_CPF'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF6'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nome'																	, ; //XB_DESCSPA
	'Nome'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UF6_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF6'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Filial'																, ; //XB_DESCRI
	'Sucursal'																, ; //XB_DESCSPA
	'Branch'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UF6_FILIAL'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF6'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'CPF'																	, ; //XB_DESCRI
	'CPF'																	, ; //XB_DESCSPA
	'CPF'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UF6_CPF'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF6'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UF6_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF6'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nome'																	, ; //XB_DESCSPA
	'Nome'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UF6_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF6'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Filial'																, ; //XB_DESCRI
	'Sucursal'																, ; //XB_DESCSPA
	'Branch'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UF6_FILIAL'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF6'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nome'																	, ; //XB_DESCSPA
	'Nome'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UF6_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF6'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UF6_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF6'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'CPF'																	, ; //XB_DESCRI
	'CPF'																	, ; //XB_DESCSPA
	'CPF'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UF6_CPF'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF6'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UF6->UF6_CODIGO'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UF6'																	, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UF6->UF6_STATUS ==@#"A"'												} ) //XB_CONTEM

//
// Consulta UG3
//
aAdd( aSXB, { ;
	'UG3'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Religiao'																, ; //XB_DESCRI
	'Religiao'																, ; //XB_DESCSPA
	'Religiao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UG3'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UG3'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UG3'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UG3'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UG3_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UG3'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UG3_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UG3'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UG3_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UG3'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UG3_DESC'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UG3'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UG3->UG3_CODIGO'														} ) //XB_CONTEM

//
// Consulta UH8
//
aAdd( aSXB, { ;
	'UH8'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Layout de Importacao'													, ; //XB_DESCRI
	'Layout de Importacao'													, ; //XB_DESCSPA
	'Layout de Importacao'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UH8'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UH8'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UH8'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UH8'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UH8_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UH8'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UH8_DESCRI'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UH8'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UH8->UH8_CODIGO'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UH8'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UH8->UH8_DESCRI'														} ) //XB_CONTEM

//
// Consulta UI2
//
aAdd( aSXB, { ;
	'UI2'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Planos de Seguro'														, ; //XB_DESCRI
	'Planos de Seguro'														, ; //XB_DESCSPA
	'Planos de Seguro'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UI2'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UI2'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UI2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UI2_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UI2'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UI2_DESCRI'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UI2'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UI2->UI2_CODIGO'														} ) //XB_CONTEM

//
// Consulta UJ5
//
aAdd( aSXB, { ;
	'UJ5'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Regra de Contrato'														, ; //XB_DESCRI
	'Regra de Contrato'														, ; //XB_DESCSPA
	'Regra de Contrato'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJ5'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJ5'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJ5'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJ5'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJ5_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJ5'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJ5_DESCRI'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJ5'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJ5_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJ5'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJ5_DESCRI'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJ5'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJ5->UJ5_CODIGO'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJ5'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJ5->UJ5_DESCRI'														} ) //XB_CONTEM

//
// Consulta UJ5B
//
aAdd( aSXB, { ;
	'UJ5B'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'REGRA BENEFICIARIO'													, ; //XB_DESCRI
	'REGRA BENEFICIARIO'													, ; //XB_DESCSPA
	'REGRA BENEFICIARIO'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJ5'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJ5B'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJ5B'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJ5_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJ5B'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJ5_DESCRI'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJ5B'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJ5->UJ5_CODIGO'														} ) //XB_CONTEM

//
// Consulta UJA
//
aAdd( aSXB, { ;
	'UJA'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Categ. Profissionais'													, ; //XB_DESCRI
	'Categ. Profissionais'													, ; //XB_DESCSPA
	'Categ. Profissionais'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJA'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJA'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJA'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJA'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Filial'																, ; //XB_DESCRI
	'Sucursal'																, ; //XB_DESCSPA
	'Branch'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJA_FILIAL'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJA_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJA_DESCRI'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Filial'																, ; //XB_DESCRI
	'Sucursal'																, ; //XB_DESCSPA
	'Branch'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJA_FILIAL'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJA_DESCRI'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJA'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJA_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJA'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJA->UJA_CODIGO'														} ) //XB_CONTEM

//
// Consulta UJB
//
aAdd( aSXB, { ;
	'UJB'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Profissionais'															, ; //XB_DESCRI
	'Profissionais'															, ; //XB_DESCSPA
	'Profissionais'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJB'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJB'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJB'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nome'																	, ; //XB_DESCSPA
	'Nome'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJB'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJB'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Filial'																, ; //XB_DESCRI
	'Sucursal'																, ; //XB_DESCSPA
	'Branch'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJB_FILIAL'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJB'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJB_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJB'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nome'																	, ; //XB_DESCSPA
	'Nome'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJB_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJB'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Filial'																, ; //XB_DESCRI
	'Sucursal'																, ; //XB_DESCSPA
	'Branch'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJB_FILIAL'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJB'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Nome'																	, ; //XB_DESCRI
	'Nome'																	, ; //XB_DESCSPA
	'Nome'																	, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJB_NOME'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJB'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJB_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJB'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJB->UJB_CODIGO'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJB'																	, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJB->UJB_STATUS ==@#"A"'												} ) //XB_CONTEM

//
// Consulta UJC
//
aAdd( aSXB, { ;
	'UJC'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Locais de Remocao'														, ; //XB_DESCRI
	'Locais de Remocao'														, ; //XB_DESCSPA
	'Locais de Remocao'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJC'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJC'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJC'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJC'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJC'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJC_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJC'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJC_DESCRI'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJC'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJC_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJC'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJC_DESCRI'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJC'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJC->UJC_CODIGO'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJC'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJC->UJC_DESCRI'														} ) //XB_CONTEM

//
// Consulta UJD
//
aAdd( aSXB, { ;
	'UJD'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Locais de Velorio'														, ; //XB_DESCRI
	'Locais de Velorio'														, ; //XB_DESCSPA
	'Locais de Velorio'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJD'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJD'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJD'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJD'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJD'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJD_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJD'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJD_DESCRI'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJD'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJD_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJD'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJD_DESCRI'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJD'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJD->UJD_CODIGO'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJD'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJD->UJD_DESCRI'														} ) //XB_CONTEM

//
// Consulta UJE
//
aAdd( aSXB, { ;
	'UJE'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Locais Sepultamento'													, ; //XB_DESCRI
	'Locais Sepultamento'													, ; //XB_DESCSPA
	'Locais Sepultamento'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJE'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJE'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJE'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJE'																	, ; //XB_ALIAS
	'3'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Cadastra Novo'															, ; //XB_DESCRI
	'Incluye Nuevo'															, ; //XB_DESCSPA
	'Add New'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'01'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJE'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJE_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJE'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJE_DESCRI'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJE'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJE_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJE'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJE_DESCRI'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJE'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJE->UJE_CODIGO'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJE'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJE->UJE_DESCRI'														} ) //XB_CONTEM

//
// Consulta UJH
//
aAdd( aSXB, { ;
	'UJH'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Convalescente'															, ; //XB_DESCRI
	'Convalescente'															, ; //XB_DESCSPA
	'Convalescente'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJH'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJH'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJH'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJH_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJH'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Beneficiario'															, ; //XB_DESCRI
	'Beneficiario'															, ; //XB_DESCSPA
	'Beneficiario'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJH_CODBEN'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJH'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJH->UJH_CODIGO'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJH'																	, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UF2->UF2_CODIGO == UJH->UJH_CONTRA'									} ) //XB_CONTEM

//
// Consulta UJJ
//
aAdd( aSXB, { ;
	'UJJ'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Modelos de Termos'														, ; //XB_DESCRI
	'Modelos de Termos'														, ; //XB_DESCSPA
	'Modelos de Termos'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJJ'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJJ'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJJ'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJJ_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJJ'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descrição'																, ; //XB_DESCRI
	'Descrição'																, ; //XB_DESCSPA
	'Descrição'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJJ_DESCRI'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJJ'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJJ->UJJ_CODIGO'														} ) //XB_CONTEM

//
// Consulta UJKVAR
//
aAdd( aSXB, { ;
	'UJKVAR'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'Variaveis Macro'														, ; //XB_DESCRI
	'Variaveis Macro'														, ; //XB_DESCSPA
	'Variaveis Macro'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJK'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJKVAR'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U_UTIL15VAR()'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJKVAR'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U_URETVAR(1)'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJKVAR'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U_URETVAR(2)'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJKVAR'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U_URETVAR(3)'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJKVAR'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'04'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U_URETVAR(4)'															} ) //XB_CONTEM

//
// Consulta UJLOBJ
//
aAdd( aSXB, { ;
	'UJLOBJ'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'Indicadores'															, ; //XB_DESCRI
	'Indicadores'															, ; //XB_DESCSPA
	'Indicadores'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJL'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJLOBJ'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U_UTIL15IND()'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJLOBJ'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U_URETIND()'															} ) //XB_CONTEM

//
// Consulta UJN
//
aAdd( aSXB, { ;
	'UJN'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Rotinas Termo'															, ; //XB_DESCRI
	'Rotinas Termo'															, ; //XB_DESCSPA
	'Rotinas Termo'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJN'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJN'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJN'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJN_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJN'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Rotina'																, ; //XB_DESCRI
	'Rotina'																, ; //XB_DESCSPA
	'Rotina'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJN_ROTINA'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJN'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJN_DESCRI'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJN'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'04'																	, ; //XB_COLUNA
	'Tabela'																, ; //XB_DESCRI
	'Tabela'																, ; //XB_DESCSPA
	'Tabela'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJN_TABELA'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJN'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJN->UJN_CODIGO'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJN'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'02'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJN->UJN_ROTINA'														} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJN'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'03'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJN->UJN_DESCRI'														} ) //XB_CONTEM

//
// Consulta UJNROT
//
aAdd( aSXB, { ;
	'UJNROT'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Rotina'																, ; //XB_DESCRI
	'Rotina'																, ; //XB_DESCSPA
	'Rotina'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJN'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJNROT'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Rotina'																, ; //XB_DESCRI
	'Rotina'																, ; //XB_DESCSPA
	'Rotina'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJNROT'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Rotina'																, ; //XB_DESCRI
	'Rotina'																, ; //XB_DESCSPA
	'Rotina'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJN_ROTINA'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJNROT'																, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Descricao'																, ; //XB_DESCRI
	'Descricao'																, ; //XB_DESCSPA
	'Descricao'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJN_DESCRI'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJNROT'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJN->UJN_ROTINA'														} ) //XB_CONTEM

//
// Consulta UJO
//
aAdd( aSXB, { ;
	'UJO'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Cod.Relacionamento'													, ; //XB_DESCRI
	'Cod.Relacionamento'													, ; //XB_DESCSPA
	'Cod.Relacionamento'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJO'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJO'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJO'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Sequencia'																, ; //XB_DESCRI
	'Sequencia'																, ; //XB_DESCSPA
	'Sequencia'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJO_SEQ'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJO'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Relacionamen'															, ; //XB_DESCRI
	'Relacionamen'															, ; //XB_DESCSPA
	'Relacionamen'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJO_RELACI'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJO'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJO->UJO_SEQ'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJO'																	, ; //XB_ALIAS
	'6'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJO->UJO_CODIGO == UJJ->UJJ_ROTINA'									} ) //XB_CONTEM

//
// Consulta UJU
//
aAdd( aSXB, { ;
	'UJU'																	, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'DB'																	, ; //XB_COLUNA
	'Gateway Vindi'															, ; //XB_DESCRI
	'Gateway Vindi'															, ; //XB_DESCSPA
	'Gateway Vindi'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJU'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJU'																	, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo+codigo Vindi'													, ; //XB_DESCRI
	'Codigo+codigo Vindi'													, ; //XB_DESCSPA
	'Codigo+codigo Vindi'													, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	''																		} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJU'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	'Codigo'																, ; //XB_DESCRI
	'Codigo'																, ; //XB_DESCSPA
	'Codigo'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJU_CODIGO'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJU'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'02'																	, ; //XB_COLUNA
	'Bandeira'																, ; //XB_DESCRI
	'Bandeira'																, ; //XB_DESCSPA
	'Bandeira'																, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJU_ITEM'																} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJU'																	, ; //XB_ALIAS
	'4'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'03'																	, ; //XB_COLUNA
	'Codigo Vindi'															, ; //XB_DESCRI
	'Codigo Vindi'															, ; //XB_DESCSPA
	'Codigo Vindi'															, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJU_CODVIN'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'UJU'																	, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJU->UJU_CODIGO+UJU->UJU_ITEM'											} ) //XB_CONTEM

//
// Consulta XUTL16
//
aAdd( aSXB, { ;
	'XUTL16'																, ; //XB_ALIAS
	'1'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'RE'																	, ; //XB_COLUNA
	'Consulta Termos'														, ; //XB_DESCRI
	'Consulta Termos'														, ; //XB_DESCSPA
	'Consulta Termos'														, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'UJJ'																	} ) //XB_CONTEM

aAdd( aSXB, { ;
	'XUTL16'																, ; //XB_ALIAS
	'2'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	'01'																	, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'U_RUTIL16A()'															} ) //XB_CONTEM

aAdd( aSXB, { ;
	'XUTL16'																, ; //XB_ALIAS
	'5'																		, ; //XB_TIPO
	'01'																	, ; //XB_SEQ
	''																		, ; //XB_COLUNA
	''																		, ; //XB_DESCRI
	''																		, ; //XB_DESCSPA
	''																		, ; //XB_DESCENG
	''																		, ; //XB_WCONTEM
	'&(ReadVar())'															} ) //XB_CONTEM

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSXB ) )

dbSelectArea( "SXB" )
dbSetOrder( 1 )

For nI := 1 To Len( aSXB )

	If !Empty( aSXB[nI][1] )

		If !SXB->( dbSeek( PadR( aSXB[nI][1], Len( SXB->XB_ALIAS ) ) + aSXB[nI][2] + aSXB[nI][3] + aSXB[nI][4] ) )

			If !( aSXB[nI][1] $ cAlias )
				cAlias += aSXB[nI][1] + "/"
				AutoGrLog( "Foi incluída a consulta padrão " + aSXB[nI][1] )
			EndIf

			RecLock( "SXB", .T. )

			For nJ := 1 To Len( aSXB[nI] )
				If FieldPos( aEstrut[nJ] ) > 0
					FieldPut( FieldPos( aEstrut[nJ] ), aSXB[nI][nJ] )
				EndIf
			Next nJ

			dbCommit()
			MsUnLock()

		Else

			//
			// Verifica todos os campos
			//
			For nJ := 1 To Len( aSXB[nI] )

				//
				// Se o campo estiver diferente da estrutura
				//
				If aEstrut[nJ] == SXB->( FieldName( nJ ) ) .AND. ;
					!StrTran( AllToChar( SXB->( FieldGet( nJ ) ) ), " ", "" ) == ;
					 StrTran( AllToChar( aSXB[nI][nJ]            ), " ", "" )

					cMsg := "A consulta padrão " + aSXB[nI][1] + " está com o " + SXB->( FieldName( nJ ) ) + ;
					" com o conteúdo" + CRLF + ;
					"[" + RTrim( AllToChar( SXB->( FieldGet( nJ ) ) ) ) + "]" + CRLF + ;
					", e este é diferente do conteúdo" + CRLF + ;
					"[" + RTrim( AllToChar( aSXB[nI][nJ] ) ) + "]" + CRLF +;
					"Deseja substituir ? "

					If      lTodosSim
						nOpcA := 1
					ElseIf  lTodosNao
						nOpcA := 2
					Else
						nOpcA := Aviso( "ATUALIZAÇÃO DE DICIONÁRIOS E TABELAS", cMsg, { "Sim", "Não", "Sim p/Todos", "Não p/Todos" }, 3, "Diferença de conteúdo - SXB" )
						lTodosSim := ( nOpcA == 3 )
						lTodosNao := ( nOpcA == 4 )

						If lTodosSim
							nOpcA := 1
							lTodosSim := MsgNoYes( "Foi selecionada a opção de REALIZAR TODAS alterações no SXB e NÃO MOSTRAR mais a tela de aviso." + CRLF + "Confirma a ação [Sim p/Todos] ?" )
						EndIf

						If lTodosNao
							nOpcA := 2
							lTodosNao := MsgNoYes( "Foi selecionada a opção de NÃO REALIZAR nenhuma alteração no SXB que esteja diferente da base e NÃO MOSTRAR mais a tela de aviso." + CRLF + "Confirma esta ação [Não p/Todos]?" )
						EndIf

					EndIf

					If nOpcA == 1
						RecLock( "SXB", .F. )
						FieldPut( FieldPos( aEstrut[nJ] ), aSXB[nI][nJ] )
						dbCommit()
						MsUnLock()

							If !( aSXB[nI][1] $ cAlias )
								cAlias += aSXB[nI][1] + "/"
								AutoGrLog( "Foi alterada a consulta padrão " + aSXB[nI][1] )
							EndIf

					EndIf

				EndIf

			Next

		EndIf

	EndIf

	oProcess:IncRegua2( "Atualizando Consultas Padrões (SXB)..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SXB" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} EscEmpresa
Função genérica para escolha de Empresa, montada pelo SM0

@return aRet Vetor contendo as seleções feitas.
             Se não for marcada nenhuma o vetor volta vazio

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function EscEmpresa()

//---------------------------------------------
// Parâmetro  nTipo
// 1 - Monta com Todas Empresas/Filiais
// 2 - Monta só com Empresas
// 3 - Monta só com Filiais de uma Empresa
//
// Parâmetro  aMarcadas
// Vetor com Empresas/Filiais pré marcadas
//
// Parâmetro  cEmpSel
// Empresa que será usada para montar seleção
//---------------------------------------------
Local   aRet      := {}
Local   aSalvAmb  := GetArea()
Local   aSalvSM0  := {}
Local   aVetor    := {}
Local   cMascEmp  := "??"
Local   cVar      := ""
Local   lChk      := .F.
Local   lOk       := .F.
Local   lTeveMarc := .F.
Local   oNo       := LoadBitmap( GetResources(), "LBNO" )
Local   oOk       := LoadBitmap( GetResources(), "LBOK" )
Local   oDlg, oChkMar, oLbx, oMascEmp, oSay
Local   oButDMar, oButInv, oButMarc, oButOk, oButCanc

Local   aMarcadas := {}


If !MyOpenSm0(.F.)
	Return aRet
EndIf


dbSelectArea( "SM0" )
aSalvSM0 := SM0->( GetArea() )
dbSetOrder( 1 )
dbGoTop()

While !SM0->( EOF() )

	If aScan( aVetor, {|x| x[2] == SM0->M0_CODIGO} ) == 0
		aAdd(  aVetor, { aScan( aMarcadas, {|x| x[1] == SM0->M0_CODIGO .and. x[2] == SM0->M0_CODFIL} ) > 0, SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_NOME, SM0->M0_FILIAL } )
	EndIf

	dbSkip()
End

RestArea( aSalvSM0 )

Define MSDialog  oDlg Title "" From 0, 0 To 280, 395 Pixel

oDlg:cToolTip := "Tela para Múltiplas Seleções de Empresas/Filiais"

oDlg:cTitle   := "Selecione a(s) Empresa(s) para Atualização"

@ 10, 10 Listbox  oLbx Var  cVar Fields Header " ", " ", "Empresa" Size 178, 095 Of oDlg Pixel
oLbx:SetArray(  aVetor )
oLbx:bLine := {|| {IIf( aVetor[oLbx:nAt, 1], oOk, oNo ), ;
aVetor[oLbx:nAt, 2], ;
aVetor[oLbx:nAt, 4]}}
oLbx:BlDblClick := { || aVetor[oLbx:nAt, 1] := !aVetor[oLbx:nAt, 1], VerTodos( aVetor, @lChk, oChkMar ), oChkMar:Refresh(), oLbx:Refresh()}
oLbx:cToolTip   :=  oDlg:cTitle
oLbx:lHScroll   := .F. // NoScroll

@ 112, 10 CheckBox oChkMar Var  lChk Prompt "Todos" Message "Marca / Desmarca"+ CRLF + "Todos" Size 40, 007 Pixel Of oDlg;
on Click MarcaTodos( lChk, @aVetor, oLbx )

// Marca/Desmarca por mascara
@ 113, 51 Say   oSay Prompt "Empresa" Size  40, 08 Of oDlg Pixel
@ 112, 80 MSGet oMascEmp Var  cMascEmp Size  05, 05 Pixel Picture "@!"  Valid (  cMascEmp := StrTran( cMascEmp, " ", "?" ), oMascEmp:Refresh(), .T. ) ;
Message "Máscara Empresa ( ?? )"  Of oDlg
oSay:cToolTip := oMascEmp:cToolTip

@ 128, 10 Button oButInv    Prompt "&Inverter"  Size 32, 12 Pixel Action ( InvSelecao( @aVetor, oLbx, @lChk, oChkMar ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Inverter Seleção" Of oDlg
oButInv:SetCss( CSSBOTAO )
@ 128, 50 Button oButMarc   Prompt "&Marcar"    Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .T. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Marcar usando" + CRLF + "máscara ( ?? )"    Of oDlg
oButMarc:SetCss( CSSBOTAO )
@ 128, 80 Button oButDMar   Prompt "&Desmarcar" Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .F. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Desmarcar usando" + CRLF + "máscara ( ?? )" Of oDlg
oButDMar:SetCss( CSSBOTAO )
@ 112, 157  Button oButOk   Prompt "Processar"  Size 32, 12 Pixel Action (  RetSelecao( @aRet, aVetor ), IIf( Len( aRet ) > 0, oDlg:End(), MsgStop( "Ao menos um grupo deve ser selecionado", "UPDVIR4" ) ) ) ;
Message "Confirma a seleção e efetua" + CRLF + "o processamento" Of oDlg
oButOk:SetCss( CSSBOTAO )
@ 128, 157  Button oButCanc Prompt "Cancelar"   Size 32, 12 Pixel Action ( IIf( lTeveMarc, aRet :=  aMarcadas, .T. ), oDlg:End() ) ;
Message "Cancela o processamento" + CRLF + "e abandona a aplicação" Of oDlg
oButCanc:SetCss( CSSBOTAO )

Activate MSDialog  oDlg Center

RestArea( aSalvAmb )
dbSelectArea( "SM0" )
dbCloseArea()

Return  aRet


//--------------------------------------------------------------------
/*/{Protheus.doc} MarcaTodos
Função auxiliar para marcar/desmarcar todos os ítens do ListBox ativo

@param lMarca  Contéudo para marca .T./.F.
@param aVetor  Vetor do ListBox
@param oLbx    Objeto do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MarcaTodos( lMarca, aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := lMarca
Next nI

oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} InvSelecao
Função auxiliar para inverter a seleção do ListBox ativo

@param aVetor  Vetor do ListBox
@param oLbx    Objeto do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function InvSelecao( aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := !aVetor[nI][1]
Next nI

oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} RetSelecao
Função auxiliar que monta o retorno com as seleções

@param aRet    Array que terá o retorno das seleções (é alterado internamente)
@param aVetor  Vetor do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function RetSelecao( aRet, aVetor )
Local  nI    := 0

aRet := {}
For nI := 1 To Len( aVetor )
	If aVetor[nI][1]
		aAdd( aRet, { aVetor[nI][2] , aVetor[nI][3], aVetor[nI][2] +  aVetor[nI][3] } )
	EndIf
Next nI

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} MarcaMas
Função para marcar/desmarcar usando máscaras

@param oLbx     Objeto do ListBox
@param aVetor   Vetor do ListBox
@param cMascEmp Campo com a máscara (???)
@param lMarDes  Marca a ser atribuída .T./.F.

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MarcaMas( oLbx, aVetor, cMascEmp, lMarDes )
Local cPos1 := SubStr( cMascEmp, 1, 1 )
Local cPos2 := SubStr( cMascEmp, 2, 1 )
Local nPos  := oLbx:nAt
Local nZ    := 0

For nZ := 1 To Len( aVetor )
	If cPos1 == "?" .or. SubStr( aVetor[nZ][2], 1, 1 ) == cPos1
		If cPos2 == "?" .or. SubStr( aVetor[nZ][2], 2, 1 ) == cPos2
			aVetor[nZ][1] := lMarDes
		EndIf
	EndIf
Next

oLbx:nAt := nPos
oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} VerTodos
Função auxiliar para verificar se estão todos marcados ou não

@param aVetor   Vetor do ListBox
@param lChk     Marca do CheckBox do marca todos (referncia)
@param oChkMar  Objeto de CheckBox do marca todos

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function VerTodos( aVetor, lChk, oChkMar )
Local lTTrue := .T.
Local nI     := 0

For nI := 1 To Len( aVetor )
	lTTrue := IIf( !aVetor[nI][1], .F., lTTrue )
Next nI

lChk := IIf( lTTrue, .T., .F. )
oChkMar:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} MyOpenSM0
Função de processamento abertura do SM0 modo exclusivo

@author TOTVS Protheus
@since  26/03/2020
@obs    Gerado por EXPORDIC - V.6.3.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MyOpenSM0(lShared)
Local lOpen := .F.
Local nLoop := 0

If FindFunction( "OpenSM0Excl" )
	For nLoop := 1 To 20
		If OpenSM0Excl(,.F.)
			lOpen := .T.
			Exit
		EndIf
		Sleep( 500 )
	Next nLoop
Else
	For nLoop := 1 To 20
		dbUseArea( .T., , "SIGAMAT.EMP", "SM0", lShared, .F. )

		If !Empty( Select( "SM0" ) )
			lOpen := .T.
			dbSetIndex( "SIGAMAT.IND" )
			Exit
		EndIf
		Sleep( 500 )
	Next nLoop
EndIf

If !lOpen
	MsgStop( "Não foi possível a abertura da tabela " + ;
	IIf( lShared, "de empresas (SM0).", "de empresas (SM0) de forma exclusiva." ), "ATENÇÃO" )
EndIf

Return lOpen


//--------------------------------------------------------------------
/*/{Protheus.doc} LeLog
Função de leitura do LOG gerado com limitacao de string

@author TOTVS Protheus
@since  26/03/2020
@obs    Gerado por EXPORDIC - V.6.3.0.1 EFS / Upd. V.5.0.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function LeLog()
Local cRet  := ""
Local cFile := NomeAutoLog()
Local cAux  := ""

FT_FUSE( cFile )
FT_FGOTOP()

While !FT_FEOF()

	cAux := FT_FREADLN()

	If Len( cRet ) + Len( cAux ) < 1048000
		cRet += cAux + CRLF
	Else
		cRet += CRLF
		cRet += Replicate( "=" , 128 ) + CRLF
		cRet += "Tamanho de exibição maxima do LOG alcançado." + CRLF
		cRet += "LOG Completo no arquivo " + cFile + CRLF
		cRet += Replicate( "=" , 128 ) + CRLF
		Exit
	EndIf

	FT_FSKIP()
End

FT_FUSE()

Return cRet


/////////////////////////////////////////////////////////////////////////////
