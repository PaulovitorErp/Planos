#include "totvs.ch"

#define DMPAPER_A4 9    // A4 210 x 297 mm

/*/{Protheus.doc} RCPGR008
Impressão de Guia de autorização de Sepultamento
@author TOTVS
@since 14/04/2016
@version P12
@param nulo
@return nulo
/*/

User Function RCPGR008( cCodServico, cCodApontamento, cCodContrato )

    Local aArea             := GetArea()
    Local aAreaSB1          := SB1->(GetArea())

    Default cCodServico     := ""
    Default cCodApontamento := ""
    Default cCodContrato    := ""

    // posicino no cadastro de produto para validar se o servico e de jazigo
    SB1->( DbSetOrder(1) )
    If SB1->( MsSeek( xFilial("SB1")+cCodServico ) )

        // verifico o campo de endereco
        If SB1->B1_XREQSER == "J"

            // faco a impressão do termo de autorização de sepultamento
            Imprime( cCodApontamento, cCodContrato )

        Else
            MsgAlert("Não é possível imprimir a guia de autorização de sepultamento, o serviço executado não é destinado a um endereço de Jazigo!")
        EndIf

    EndIf

    RestArea( aAreaSB1 )
    RestArea( aArea )

Return(Nil)

/*/{Protheus.doc} Imprime
faco a impressao da guia de sepultamento
@type function
@version 
@author g.sampaio
@since 14/05/2020
@param cCodApontamento, character, codigo do apontamento
@param cCodContrato, character, codigo do contrato
@return Nil
/*/
Static Function Imprime( cCodApontamento, cCodContrato )

    Local nLin              := 0
    Local oRel              := Nil

    Default cCodApontamento := ""
    Default cCodContrato    := ""

    // inicio o objeto de impressao TmsPrinter
    oRel := TmsPrinter():New("")
    oRel:SetPortrait()
    oRel:SetPaperSize(9) //A4

    // imprimo o cabecalho do relatorio
    CabecRel( @oRel, @nLin )

    // imprimo o corpo do relatorio
    CorpoRel( @oRel, @nLin, cCodContrato, cCodApontamento )

    // imprimo o rodape do relatorio
    RodRel( @oRel, @nLin )

    oRel:Preview()

Return(Nil)

/*/{Protheus.doc} CabecRel
funcao que imprimo o cabecalho do relatorio
@type function
@version 
@author TOTVS
@since 14/04/2016
@param oRel, object, objeto do relatorio
@param nLin, numeric, variavel de linha do relatorio
@return nil
/*/
Static Function CabecRel( oRel, nLin )

    Local aArea         := GetArea()
    Local cStartPath    := ""
    Local oFont14N      := TFont():New('Arial',,14,,.T.,,,,.F.,.F.) 				//Fonte 14 Negrito

    Default nLin        := 0

    // inicio o valor da linha
    nLin := 80

    // pego o caminho da startpath
    cStartPath := GetPvProfString(GetEnvServer(),"StartPath","ERROR",GetAdv97())
    cStartPath += If(Right(cStartPath, 1) <> "\", "\", "")

    oRel:StartPage() //Inicia uma nova pagina

    // imprirmo a logo da empresa
    oRel:SayBitMap(nLin + 15,100,cStartPath + "LGMID01.png",400,214)

    // faco a impressao do titulo do relatorio
    oRel:Say(nLin + 80,900,"AUTORIZAÇÃO DE SEPULTAMENTO",oFont14N)

    // faco um salto de linhas na impressao
    nLin += 300

    RestArea( aArea )

Return(Nil)

/*/{Protheus.doc} CorpoRel
imprimo o corpo do relatorio
@type function
@version 
@author TOTVS
@since 14/04/2016
@param oRel, object, objeto de impressao do relatorio
@param nLin, numeric, numero da linha de impressao
@param cCodContrato, character, codigo do contrato
@param cCodApontamento, character, codigo do apontamento
@return return_type, return_description
/*/

Static Function CorpoRel( oRel, nLin, cCodContrato, cCodApontamento )

    Local aArea             := GetArea()
    Local aAreaU00          := U00->( GetArea() )
    Local aAreaU01          := U01->( GetArea() )
    Local aAreaU02          := U02->( GetArea() )
    Local aAreaUJV          := UJV->( GetArea() )
    Local cPortador         := ""
    Local cEndereco         := ""
    Local cBairro           := ""
    Local cMunicipio        := ""
    Local cEstado           := ""
    Local cCEP              := ""
    Local cRG               := ""
    Local cCPF              := ""
    Local cTelefone         := ""
    Local cDtNasc           := ""
    Local lImpAut           := SuperGetMV("MV_XIMPAUT",.F.,.F.)
    Local oFont10			:= TFont():New('Arial',,10,,.F.,,,,.F.,.F.) 				//Fonte 10 Normal
    Local oFont12N		    := TFont():New('Arial',,12,,.T.,,,,.F.,.F.) 			 	//Fonte 12 Negrito

    Default nLin            := 0
    Default cCodContrato    := ""
    Default cCodApontamento := ""

    // posiciono no contrato
    U00->( DbSetOrder(1) )
    If U00->( MsSeek( xFilial("U00")+cCodContrato ) )

        // posiciono nos itens do contrato
        U01->(DbSetOrder(1)) //U01_FILIAL+U01_CODIGO
        If U01->(DbSeek(xFilial("U01")+U00->U00_CODIGO))

            // posiciono no apontamento
            UJV->( DbSetOrder(1) ) // UJV_FILIAL+UJV_CODIGO
            If UJV->( MsSeek(xFilial("UJV")+cCodApontamento) )

                // verifico se imprimo a autorizacao com os dados do autorizado
                if lImpAut .And. !Empty(UJV->UJV_AUTORI) .And. MsgYesNo("Deseja Imprimir a Autorização de Sepultamento com os dados do Autorizado?")

                    // posiciono no cadastro do autorizado
                    U02->( DbSetOrder(1) )
                    If U02->( MsSeek( xFilial("U02")+U00->U00_CODIGO+UJV->UJV_AUTORI ) )

                        cPortador   := U02->U02_NOME
                        cEndereco   := AllTrim(U02->U02_END) + Space(1) + U02->U02_COMPLE
                        cBairro     := U02->U02_BAIRRO
                        cMunicipio  := U02->U02_MUN
                        cEstado     := U02->U02_EST
                        cCEP        := Transform(U02->U02_CEP,"@R 99999-999")
                        cRG         := U02->U02_CI + Space(1) + U02->U02_ORGAOE
                        cCPF        := Transform(U02->U02_CPF,"@R 999.999.999-99")
                        cTelefone   := AllTrim(U02->U02_DDD) + Space(1) + U02->U02_FONE
                        cDtNasc     := DToC(U02->U02_DTNASC)

                    EndIf

                else

                    cPortador   := U00->U00_NOMCLI
                    cEndereco   := AllTrim(U00->U00_END) + Space(1) + U00->U00_COMPLE
                    cBairro     := U00->U00_BAIRRO
                    cMunicipio  := U00->U00_MUN
                    cEstado     := U00->U00_UF
                    cCEP        := Transform(U00->U00_CEP,"@R 99999-999")
                    cRG         := U00->U00_RG
                    cCPF        := Transform(U00->U00_CGC,"@R 999.999.999-99")
                    cTelefone   := AllTrim(U00->U00_DDD) + Space(1) + U00->U00_TEL
                    cDtNasc     := DToC(U00->U00_DTNASC)

                endIf

                // ============================================================
                // imprimo o nome do cliente do contrato
                // ============================================================
                oRel:Say( nLin     , 120, "Portador"        , oFont10 )
                oRel:Box( nLin + 50, 120, nLin + 120        , 2240 )
                oRel:Say( nLin + 70, 130, cPortador         , oFont10 )
                nLin += 200

                // ============================================================
                // imprimo o endereco do cliente do contrato
                // ============================================================
                oRel:Say( nLin     , 120, "Endereço"    , oFont10 )
                oRel:Box( nLin + 50, 120, nLin + 120    , 2240 )
                oRel:Say( nLin + 70, 130, cEndereco     , oFont10 )
                nLin += 200

                // ============================================================
                // imprimo a continuacao do endereco do cliente do contrato
                // ============================================================

                // bairro
                oRel:Say( nLin     , 120, "Bairro"          , oFont10 )
                oRel:Box( nLin + 50, 120, nLin + 120        , 2240 )
                oRel:Say( nLin + 70, 130, cBairro           , oFont10 )

                // municipio
                oRel:Say( nLin     , 710, "Municipio"       , oFont10)
                oRel:Box( nLin + 50, 710, nLin + 120        , 2240)
                oRel:Say( nLin + 70, 720, cMunicipio        , oFont10)

                // estado
                oRel:Say( nLin     , 1300, "Estado"    , oFont10 )
                oRel:Box( nLin + 50, 1300, nLin + 120  , 2240 )
                oRel:Say( nLin + 70, 1310, cEstado , oFont10 )

                // CEP
                oRel:Say( nLin     , 1900, "CEP", oFont10 )
                oRel:Box( nLin + 50, 1900, nLin + 120,2240 )
                oRel:Say( nLin + 70, 1910, cCEP ,oFont10)
                nLin += 200

                // ============================================================
                // imprimo os dados pessoais do cliente do contrato
                // ============================================================

                // RG
                oRel:Say( nLin     , 120, "RG"         , oFont10 )
                oRel:Box( nLin + 50, 120, nLin + 120   , 2240 )
                oRel:Say( nLin + 70, 130, cRG         , oFont10 )

                // CPF
                oRel:Say( nLin     , 710, "CPF", oFont10 )
                oRel:Box( nLin + 50, 710, nLin + 120, 2240 )
                oRel:Say( nLin + 70, 720, cCPF  , oFont10 )

                // telefone
                oRel:Say( nLin     , 1300, "Telefone",oFont10 )
                oRel:Box( nLin + 50, 1300,  nLin + 120,2240 )
                oRel:Say( nLin + 70, 1310, cTelefone, oFont10 )

                // data de nascimento
                oRel:Say( nLin     , 1900, "Dt. Nasc.", oFont10 )
                oRel:Box( nLin + 50, 1900, nLin + 120, 2240 )
                oRel:Say( nLin + 70, 1910, cDtNasc, oFont10)
                nLin += 200

                // ============================================================
                // imprimo os do autorizado do apontamento e contrato
                // ============================================================

                // verifico se imprimo a autorizacao com os dados do autorizado
                if lImpAut .And. !Empty(UJV->UJV_AUTORI)

                    // contrato
                    oRel:Say( nLin     , 120, "Contrato", oFont10 )
                    oRel:Box( nLin + 50, 120, nLin + 120, 2240 )
                    oRel:Say( nLin + 70, 130, U00->U00_CODIGO, oFont10 )
                    nLin += 200
                else

                    // concessionario
                    oRel:Say( nLin     , 120, "Concessionário", oFont10 )
                    oRel:Box( nLin + 50, 120, nLin + 120, 2240 )
                    oRel:Say( nLin + 70, 130, RetNomeAutorizado(U00->U00_CODIGO, UJV->UJV_AUTORI), oFont10 )

                    // contrato
                    oRel:Say( nLin     , 1900, "Contrato"      , oFont10 )
                    oRel:Box( nLin + 50, 1900, nLin + 120      , 2240 )
                    oRel:Say( nLin + 70, 1910, U00->U00_CODIGO , oFont10 )
                    nLin += 200

                endIf

                // ============================================================
                // dados do falecido
                // ============================================================
                oRel:Say(nLin     , 120,  "Falecido"   , oFont10)
                oRel:Box(nLin + 50, 120,  nLin + 120   , 2240)
                oRel:Say(nLin + 70, 130,  UJV->UJV_NOME, oFont10)
                nLin += 200

                // ============================================================
                // dados do falecido
                // ============================================================

                // conforme
                oRel:Say( nLin      , 120, "Conforme:", oFont10 )
                oRel:Box( nLin      , 500, nLin + 70  , 580 )
                oRel:Line( nLin + 70, 580, nLin + 70  , 780 )

                // pego
                oRel:Say( nLin + 30 , 600 , "PAGO"   , oFont10 )
                oRel:Box( nLin      , 980 , nLin + 70, 1060 )
                oRel:Line( nLin + 70, 1060, nLin + 70, 1260 )

                // nota fiscal
                oRel:Say( nLin + 30 , 1080, "NF"     , oFont10 )
                oRel:Box( nLin      , 1460, nLin + 70, 1540 )
                oRel:Line( nLin + 70, 1540, nLin + 70, 1740 )

                // codigo totvs
                oRel:Say( nLin + 30 , 1560, "TOTVS" , oFont10 )
                oRel:Box( nLin      , 1940, nLin + 70, 2020 )
                oRel:Line( nLin + 70, 2020, nLin + 70, 2220 )
                nLin += 200

                // ============================================================
                // dados do endereco
                // ============================================================

                oRel:Say( nLin, 1110, "Localização", oFont12N )
                nLin += 100

                // quadra
                oRel:Say( nLin, 120, "Quadra:"      , oFont10 )
                oRel:Say( nLin, 255, UJV->UJV_QUADRA, oFont10 )

                // modulo
                oRel:Say( nLin, 600, "Módulo:"      , oFont10 )
                oRel:Say( nLin, 740, UJV->UJV_MODULO, oFont10 )

                // jazigo
                oRel:Say( nLin, 1080, "Jazigo:"      , oFont10 )
                oRel:Say( nLin, 1200, UJV->UJV_JAZIGO, oFont10 )

                // tipo
                oRel:Say( nLin, 1560, "Tipo:"                               , oFont10 )
                oRel:Say( nLin, 1660, Iif("3" $ U01->U01_DESCRI,"3-C","6-C"), oFont10 )

                // gaveta
                oRel:Say( nLin, 2040, "Gaveta:"      , oFont10 )
                oRel:Say( nLin, 2175, UJV->UJV_GAVETA, oFont10 )
                nLin += 200

                // ============================================================
                // dados do servico
                // ============================================================

                // data do servico
                oRel:Say( nLin, 400, "Data serviço:"    , oFont10 )
                oRel:Say( nLin, 620, DToC(UJV->UJV_DTSEPU), oFont10 )

                // hora do servico
                oRel:Say( nLin, 1320, "Hora serviço:"                    , oFont10 )
                oRel:Say( nLin, 1540, Transform(UJV->UJV_HORASE,"@R 99:99"), oFont10 )
                nLin += 200

                // ============================================================
                // dados do velorio
                // ============================================================

                // local do velorio
                oRel:Say( nLin, 120, "Local do Velório:", oFont10 )
                oRel:Box( nLin, 500, nLin + 70, 580 )

                // cemiterio
                oRel:Say( nLin + 27 , 600, "Cemitério"  , oFont10 )
                oRel:Line( nLin + 70, 580, nLin + 70    , 880 )

                // fora
                oRel:Box( nLin      , 1180, nLin + 70, 1260 )
                oRel:Say( nLin + 27 , 1280, "Fora"   , oFont10 )
                oRel:Line( nLin + 70, 1260, nLin + 70, 1560 )

                // sala
                oRel:Box( nLin      , 1840, nLin + 70   , 1920 )
                oRel:Say( nLin + 27 , 1940, "Sala"      , oFont10 )
                oRel:Line( nLin + 70, 1920, nLin + 70   , 2240 )
                nLin += 200

                // observacao
                oRel:Say( nLin + 20, 120, "Observação:" , oFont10 )
                oRel:Say( nLin + 20, 330, UJV->UJV_OBS  , oFont10 )
                nLin += 200

                // atendente
                oRel:Say( nLin, 120, "Atendente:", oFont10 )
                oRel:Box( nLin, 500, nLin + 70   , 1000 )
                oRel:Say( nLin + 20, 510         , cUserName, oFont10 )

                // data
                oRel:Say( nLin     , 1200, "Data:", oFont10 )
                oRel:Box( nLin     , 1360, nLin + 70, 1700 )
                oRel:Say( nLin + 20, 1370, DToC(dDataBase), oFont10 )

                // hora
                oRel:Say( nLin     , 1900, "Hora:"           , oFont10 )
                oRel:Box( nLin     , 2040, nLin + 70         , 2240 )
                oRel:Say( nLin + 20, 2050, SubStr(Time(),1,5), oFont10 )
                nLin += 200

                // assinatura
                oRel:Say( nLin      , 120, "Assinatura:", oFont10 )
                oRel:Line( nLin + 50, 340, nLin + 50    , 2240 )
                nLin += 200

                // funeraria
                oRel:Say( nLin,120,"Funerária:",oFont10)
                oRel:Say( nLin,300,UJV->UJV_FUNERA,oFont10)

            EndIf

        EndIf

    EndIf

    RestArea( aAreaUJV )
    RestArea( aAreaU02 )
    RestArea( aAreaU01 )
    RestArea( aAreaU00 )
    RestArea( aArea )

Return(Nil)

/*/{Protheus.doc} RodRel
imprimo o rodape do relatorio
@type function
@version 
@author g.sampaio
@since 13/05/2020
@return return_type, return_description
/*/
Static Function RodRel( oRel, nLin)

    Local oFont8	:= TFont():New('Arial',,8,,.F.,,,,.F.,.F.) 					//Fonte 8 Normal

    Default nLin    := 0

    oRel:Line(3320,0120,3320,2240)
    oRel:Say(3350,0110,"TOTVS - Protheus",oFont8)

    oRel:EndPage()

Return( Nil )

/*/{Protheus.doc} RetNomeAutorizado
funcao para retornar o nome do autorizado
@type function
@version 
@author g.sampaio
@since 14/05/2020
@param cCodContrato, character, codigo do contrato
@param cCodAutoriz, character, codigo do autorizado
@return return_type, return_description
/*/
Static Function RetNomeAutorizado( cCodContrato, cCodAutoriz )

    Local aArea             := GetArea()
    Local aAreaU02          := U02->( GetArea() )
    Local cRetorno          := ""

    Default cCodContrato    := ""
    Default cCodAutoriz     := ""

    // posiciono no cadastro do autorizado
    U02->( DbSetOrder(1) )
    If U02->( MsSeek( xFilial("U02")+cCodContrato+cCodAutoriz ) )
        cRetorno    := U02->U02_NOME // nome do autorizado
    EndIf

    RestArea( aAreaU02 )
    RestArea( aArea )

Return( cRetorno )
