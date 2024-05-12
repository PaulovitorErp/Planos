#include "totvs.ch"
#include "topconn.ch"

/*/{Protheus.doc} RCPGR030
Relatório para a relacao de enderecamento
? Informações :

Relação de Jazigo ordenado por endereço (Quadra, Módulo, Jazigo)
Trazer a descrição da Quadra
Trazer o Nome do Sepultado e data do sepultamento
Totalizador de jazigos ocupados, jazigos endereçados livres, jazigos livres
@author g.sampaio
@since 05/02/2020
@version P12
@param nulo
@return nulo
@history 26/06/2020, g.sampaio, VPDV-474 - Retirado a descição de módulo e jazigos da impressão 
do relatório de jazigos.
/*/
User Function RCPGR030()

    Local oReport

    oReport:= ReportDef()
    oReport:PrintDialog()

Return()

/*/{Protheus.doc} ReportDef
// Na seção de definição do relatório, função ReportDef(), devem ser criados os componentes de impressão,
as seções e as células, os totalizadores e demais componentes que o usuário poderá personalizar no relatório.

@author g.sampaio
@since 05/02/2019
@version 1.0

@type function
/*/
Static Function ReportDef()

    Local oReport		:= NIL
    Local oEnderecos	:= NIL
    Local oTotal		:= NIL
    Local cTitle		:= "Relatório de Endereçamento"
    Local cPerg			:= "RCPGR030"

    oReport:= TReport():New(cPerg,cTitle,"RCPGR030",{|oReport| PrintReport(oReport,oEnderecos,oTotal)},"Este relatório apresenta a situação de cada endereço.")
    //oReport:SetPortrait() 			// Orientação retrato
    oReport:SetLandscape()		// Orientação paisagem
    //oReport:HideHeader()  		// Nao imprime cabeçalho padrão do Protheus
    //oReport:HideFooter()			// Nao imprime rodapé padrão do Protheus
    oReport:HideParamPage()			// Inibe impressão da pagina de parametros
    oReport:SetUseGC( .F. ) 		// Desabilita o botão <Gestao Corporativa> do relatório
    //oReport:DisableOrientation()  	// Desabilita a seleção da orientação (retrato/paisagem)
    //oReport:cFontBody := "Arial"
    oReport:nFontBody := 9

    AjustaSx1(cPerg) // cria as perguntas para gerar o relatorio
    Pergunte(oReport:GetParam(),.F.)

    //ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
    //Criacao da secao utilizada pelo relatorio
    //
    //TRSection():New
    //ExpO1 : Objeto TReport que a secao pertence
    //ExpC2 : Descricao da seção
    //ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela
    //        sera considerada como principal para a seção.
    //ExpA4 : Array com as Ordens do relatorio
    //ExpL5 : Carrega campos do SX3 como celulas
    //        Default : False
    //ExpL6 : Carrega ordens do Sindex
    //        Default : False
    //
    //¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
    //ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
    //Criacao da celulas da secao do relatorio
    //
    //TRCell():New
    //ExpO1 : Objeto TSection que a secao pertence
    //ExpC2 : Nome da celula do relatório. O SX3 será consultado
    //ExpC3 : Nome da tabela de referencia da celula
    //ExpC4 : Titulo da celula
    //        Default : X3Titulo()
    //ExpC5 : Picture
    //        Default : X3_PICTURE
    //ExpC6 : Tamanho
    //        Default : X3_TAMANHO
    //ExpL7 : Informe se o tamanho esta em pixel
    //        Default : False
    //ExpB8 : Bloco de código para impressao.
    //        Default : ExpC2
    //
    //¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

    oEnderecos := TRSection():New(oReport,"Enderecos",{"TRBEND"})
    oEnderecos:SetHeaderPage(.F.)
    oEnderecos:SetHeaderSection(.T.) // Habilita Impressao Cabecalho no Topo da Pagina
    oEnderecos:SetTotalInLine(.F.)

    //////////////////////////////////////////////////////////////////////////
    ////////////////// COLUNAS QUE SERAO IMPRESSAS //////////////////////////
    //////////////////////////////////////////////////////////////////////////

    TRCell():New(oEnderecos,"QUADRA"			,"TRBEND", "Quadra"	        , 		PesqPict("U04","U04_QUADRA")	, TamSX3("U04_QUADRA")[1]+10)
    TRCell():New(oEnderecos,"DESC_QUADRA"		,"TRBEND", "Desc.Quadra"    , 		PesqPict("U04","U08_DESC")	    , TamSX3("U08_DESC")[1]+10)
    TRCell():New(oEnderecos,"MODULO"		    ,"TRBEND", "Modulo "	    , 		PesqPict("U04","U04_MODULO")	, TamSX3("U04_MODULO")[1]+10)
    TRCell():New(oEnderecos,"JAZIGO"			,"TRBEND", "Jazigo"		    , 		PesqPict("U04","U04_JAZIGO")	, TamSX3("U04_JAZIGO")[1]+10)
    TRCell():New(oEnderecos,"GAVETA_UTILIZACAO"	,"TRBEND", "Gaveta"	        ,		PesqPict("U04","U04_GAVETA")  	, TamSX3("U04_GAVETA")[1]+15)
    TRCell():New(oEnderecos,"DATA_UTILIZACAO"	,"TRBEND", "Dt.Utilizacao"	,		PesqPict("U04","U04_DTUTIL")  	, TamSX3("U04_DTUTIL")[1]+20)
    TRCell():New(oEnderecos,"OCUPAG"	        ,"TRBEND", "Ocupa Gav"      ,		"@!"  	, 20 )
    TRCell():New(oEnderecos,"CONTRATO"	        ,"TRBEND", "Contrato"	    ,		PesqPict("U04","U04_CODIGO")  	, TamSX3("U04_CODIGO")[1]+10)
    TRCell():New(oEnderecos,"QUEM_UTILIZOU"  	,"TRBEND", "Sepultado"	    ,		PesqPict("U04","U04_QUEMUT")  	, TamSX3("U04_QUEMUT")[1]+40)

    //////////////////////////////////////////////////////////////////////////
    ////////////////// 		TOTALIZADORES GERAIS	//////////////////////////
    //////////////////////////////////////////////////////////////////////////
    oTotal := TRSection():New(oReport,"Total Geral",{}) //TRSection():New(oReport,"Total Geral",{},,,,,,,,,,,.T.,,,,,1)
    oTotal:SetHeaderPage(.F.)
    oTotal:SetHeaderSection(.T.)

    TRCell():New(oTotal,"nJazOcup"	, , "Tot.Jazigo Ocupado" 	, "@E 999 999", TamSX3("E1_VALOR ")[1]+1)
    TRCell():New(oTotal,"nJazEnde"	, , "Tot.Jazigo End.Vazio"	, "@E 999 999", TamSX3("E1_VALOR ")[1]+1)
    TRCell():New(oTotal,"nJazLivre"	, , "Tot.Jazigo Livre"	    , "@E 999 999", TamSX3("E1_VALOR ")[1]+1)

    // Alinhamento a direita dos campos de valores
    oTotal:Cell("nJazOcup"):SetHeaderAlign("RIGHT")
    oTotal:Cell("nJazEnde"):SetHeaderAlign("RIGHT")
    oTotal:Cell("nJazLivre"):SetHeaderAlign("RIGHT")

    //Impressao do Cabecalho no topo da pagina
    oReport:Section(1):SetHeaderPage()
    oReport:Section(1):SetEdit(.T.)
    oEnderecos:SetEdit(.T.)
    oReport:Section(2):SetEdit(.T.)

Return(oReport)

/*/{Protheus.doc} PrintReport
// Inicia Logica Print Report

@author g.sampaio
@since 05/02/2020
@version undefined

@type function
/*/
Static Function PrintReport(oReport,oEnderecos,oTotal)

    Local cAntChave     := ""
    Local cAtuChave     := ""
    Local cQry 			:= ""
    Local cQuadra 	    := ""
    Local cModuloDe   	:= ""
    Local cModuloAte   	:= ""
    Local cJazigoDe     := ""    
    Local cJazigoAte    := ""    
    Local nCont			:= 0
    Local nJazOcup 		:= 0
    Local nJazEnde		:= 0
    Local nJazLivre		:= 0
    Local nAberto		:= 0
    Local nSituacao     := 0

    // alimento as variaveis
    cQuadra 	:= MV_PAR01
    cModuloDe   := MV_PAR02
    cModuloAte  := MV_PAR03
    cJazigoDe 	:= MV_PAR04
    cJazigoAte 	:= MV_PAR05
    nSituacao	:= MV_PAR06
    nOcuGav     := MV_PAR07

    // verifico se o alias esta em uso
    If Select("TRBEND") > 0
        TRBEND->( dbCloseArea() )
    EndIf

    //////////////////////////////////////////////////////////////////////////
    ////// consulto os enderecamentos, ocupados, enderecados, livres ////////
    /////////////////////////////////////////////////////////////////////////

    // para ambos os enderecos e jazigos livres
    If nSituacao == 1 .Or. nSituacao == 4

        cQry := " SELECT 'LIVRES'   AS TITULO,
        cQry += " QUADRA.U08_FILIAL	AS FILIAL,
        cQry += " QUADRA.U08_CODIGO	AS QUADRA,
        cQry += " QUADRA.U08_DESC   AS DESC_QUADRA,
        cQry += " MODULO.U09_CODIGO	AS MODULO,
        cQry += " JAZIGO.U10_CODIGO	AS JAZIGO,        
        cQry += " ''                AS GAVETA_UTILIZACAO,
        cQry += " ''                AS DATA_UTILIZACAO,
        cQry += " ''                AS OCUPAG,
        cQry += " ''                AS CONTRATO,"
        cQry += " ''                AS QUEM_UTILIZOU
        cQry += " FROM " + RetSqlName("U08") + " QUADRA
        cQry += " INNER JOIN " + RetSqlName("U09") + " MODULO ON QUADRA.D_E_L_E_T_ = ' '

        cQry += " AND MODULO.D_E_L_E_T_ = ' '
        cQry += " AND MODULO.U09_FILIAL = '" + xFilial("U09") + "' "
        cQry += " AND MODULO.U09_QUADRA = QUADRA.U08_CODIGO
        cQry += " AND MODULO.U09_STATUS = 'S' "

        cQry += " INNER JOIN " + RetSqlName("U10") + " JAZIGO ON JAZIGO.D_E_L_E_T_ = ' '
        cQry += " AND JAZIGO.U10_FILIAL = '" + xFilial("U10") + "' "
        cQry += " AND JAZIGO.U10_QUADRA = MODULO.U09_QUADRA
        cQry += " AND JAZIGO.U10_MODULO = MODULO.U09_CODIGO
        cQry += " AND JAZIGO.U10_STATUS = 'S' "

        cQry += " WHERE QUADRA.D_E_L_E_T_ = ' ' "
        cQry += " AND QUADRA.U08_STATUS = 'S' "

        // filtro para quadra
        if !Empty(cQuadra)
            cQry += " AND JAZIGO.U10_QUADRA IN " + FormatIn( AllTrim(cQuadra), ";" )
        endIf

        // filtro de modulo
        if !Empty(cModuloAte)
            cQry += "   AND JAZIGO.U10_MODULO BETWEEN '" + AllTrim(cModuloDe) + "' AND '" + AllTrim(cModuloAte) + "'"
        endIf

        // filtro de jazigo
        if !Empty(cJazigoAte)
            cQry += "   AND JAZIGO.U10_CODIGO BETWEEN '" + AllTrim(cJazigoDe) + "' AND '" + AllTrim(cJazigoAte) + "'"
        endIf

        cQry += "   AND NOT EXISTS (SELECT SEPULT.U04_QUADRA
        cQry += " 					FROM " + RetSqlName("U04") + " SEPULT
        cQry += " 					WHERE SEPULT.D_E_L_E_T_ = ' '
        cQry += " 					AND SEPULT.U04_FILIAL = '" + xFilial("U04") + "' "
        cQry += " 					AND SEPULT.U04_QUADRA = JAZIGO.U10_QUADRA
        cQry += " 					AND SEPULT.U04_MODULO = JAZIGO.U10_MODULO
        cQry += " 					AND SEPULT.U04_JAZIGO = JAZIGO.U10_CODIGO)

    EndIf

    // para quando for ambos os jazigos, faco o union
    If nSituacao == 1
        cQry += " UNION ALL
    EndIf

    // para ambos os enderecos e jazigos vazios
    If nSituacao == 1 .Or. nSituacao == 3

        cQry += " SELECT 'ENDVAZIOS' AS TITULO,
        cQry += " ENDERECO.U04_FILIAL	AS FILIAL,
        cQry += " ENDERECO.U04_QUADRA	AS QUADRA,
        cQry += " QUADRA.U08_DESC	    AS DESC_QUADRA,
        cQry += " ENDERECO.U04_MODULO	AS MODULO,
        cQry += " ENDERECO.U04_JAZIGO	AS JAZIGO,        
        cQry += " ENDERECO.U04_GAVETA 	AS GAVETA_UTILIZACAO,
        cQry += " ENDERECO.U04_DTUTIL 	AS DATA_UTILIZACAO,
        cQry += " ENDERECO.U04_OCUPAG   AS OCUPAG,
        cQry += " ENDERECO.U04_CODIGO   AS CONTRATO,"
        cQry += " ENDERECO.U04_QUEMUT 	AS QUEM_UTILIZOU
        cQry += " FROM
        cQry += " " + RetSqlName("U04") + " ENDERECO

        cQry += " INNER JOIN " + RetSqlName("U08") + " QUADRA ON QUADRA.D_E_L_E_T_ = ' '
        cQry += " AND QUADRA.U08_FILIAL = '" + xFilial("U04") + "' "
        cQry += " AND QUADRA.U08_CODIGO = ENDERECO.U04_QUADRA
        cQry += " AND QUADRA.U08_STATUS = 'S' "

        cQry += " INNER JOIN " + RetSqlName("U09") + " MODULO ON MODULO.D_E_L_E_T_ = ' '

        cQry += " AND MODULO.U09_FILIAL = '" + xFilial("U09") + "' "
        cQry += " AND MODULO.U09_QUADRA = ENDERECO.U04_QUADRA
        cQry += " AND MODULO.U09_CODIGO = ENDERECO.U04_MODULO
        cQry += " AND MODULO.U09_STATUS = 'S' "

        cQry += " INNER JOIN " + RetSqlName("U10") + " JAZIGO ON JAZIGO.D_E_L_E_T_ = ' '
        cQry += " AND JAZIGO.U10_FILIAL = '" + xFilial("U10") + "' "
        cQry += " AND JAZIGO.U10_QUADRA = ENDERECO.U04_QUADRA
        cQry += " AND JAZIGO.U10_MODULO = ENDERECO.U04_MODULO
        cQry += " AND JAZIGO.U10_CODIGO = ENDERECO.U04_JAZIGO
        cQry += " AND JAZIGO.U10_STATUS = 'S' "

        cQry += " WHERE
        cQry += " ENDERECO.D_E_L_E_T_ = ' '

        // filtro para quadra
        if !Empty(cQuadra)
            cQry += " AND JAZIGO.U10_QUADRA IN " + FormatIn( AllTrim(cQuadra), ";" )
        endIf

        // filtro de modulo
        if !Empty(cModuloAte)
            cQry += "   AND JAZIGO.U10_MODULO BETWEEN '" + AllTrim(cModuloDe) + "' AND '" + AllTrim(cModuloAte) + "'"
        endIf

        // filtro de jazigo
        if !Empty(cJazigoAte)
            cQry += "   AND JAZIGO.U10_CODIGO BETWEEN '" + AllTrim(cJazigoDe) + "' AND '" + AllTrim(cJazigoAte) + "'"
        endIf

        cQry += " AND NOT EXISTS ( SELECT
        cQry += " 					SEPULT.U04_QUADRA
        cQry += " 					FROM " + RetSqlName("U04") + " SEPULT
        cQry += " 					WHERE SEPULT.D_E_L_E_T_ = ' '
        cQry += " 					AND SEPULT.U04_FILIAL = '" + xFilial("U04") + "' "
        cQry += " 					AND SEPULT.U04_QUADRA = ENDERECO.U04_QUADRA
        cQry += " 					AND SEPULT.U04_MODULO = ENDERECO.U04_MODULO
        cQry += " 					AND SEPULT.U04_JAZIGO = ENDERECO.U04_JAZIGO
        cQry += " 					AND SEPULT.U04_QUEMUT <> ' ' )

    EndIf

    // para quando for ambos os jazigos, faco o union
    If nSituacao == 1
        cQry += " UNION ALL
    EndIf

    // para ambos os enderecos e jazigos ocupados
    If nSituacao == 1 .Or. nSituacao == 2

        cQry += " SELECT
        cQry += " 'ENDOCUPADOS'         AS TITULO,
        cQry += " SEPULT.U04_FILIAL	    AS FILIAL,
        cQry += " SEPULT.U04_QUADRA	    AS QUADRA,
        cQry += " QUADRA.U08_DESC	    AS DESC_QUADRA,
        cQry += " SEPULT.U04_MODULO	    AS MODULO,        
        cQry += " SEPULT.U04_JAZIGO	    AS JAZIGO,        
        cQry += " SEPULT.U04_GAVETA 	AS GAVETA_UTILIZACAO,
        cQry += " SEPULT.U04_DTUTIL 	AS DATA_UTILIZACAO,
        cQry += " SEPULT.U04_OCUPAG   AS OCUPAG,
        cQry += " SEPULT.U04_CODIGO     AS CONTRATO,"
        cQry += " SEPULT.U04_QUEMUT 	AS QUEM_UTILIZOU
        cQry += " FROM " + RetSqlName("U04") + " SEPULT
        
        cQry += " INNER JOIN " + RetSqlName("U08") + " QUADRA ON QUADRA.D_E_L_E_T_ = ' '
        cQry += " AND QUADRA.U08_FILIAL = '" + xFilial("U08") + "' "
        cQry += " AND QUADRA.U08_CODIGO = SEPULT.U04_QUADRA
        cQry += " AND QUADRA.U08_STATUS = 'S' "

        cQry += " INNER JOIN " + RetSqlName("U09") + " MODULO ON MODULO.D_E_L_E_T_ = ' '
        cQry += " AND MODULO.U09_FILIAL = '" + xFilial("U09") + "' "
        cQry += " AND MODULO.U09_QUADRA = SEPULT.U04_QUADRA
        cQry += " AND MODULO.U09_CODIGO = SEPULT.U04_MODULO
        cQry += " AND MODULO.U09_STATUS = 'S' "
        
        cQry += " INNER JOIN " + RetSqlName("U10") + " JAZIGO ON JAZIGO.D_E_L_E_T_ = ' '
        cQry += " AND JAZIGO.U10_FILIAL = '" + xFilial("U10") + "' "
        cQry += " AND JAZIGO.U10_QUADRA = SEPULT.U04_QUADRA
        cQry += " AND JAZIGO.U10_MODULO = SEPULT.U04_MODULO
        cQry += " AND JAZIGO.U10_CODIGO = SEPULT.U04_JAZIGO
        cQry += " AND JAZIGO.U10_STATUS = 'S' "
        
        cQry += " WHERE SEPULT.D_E_L_E_T_ = ' '
        cQry += " 	AND SEPULT.U04_QUEMUT <> ' '

        if nOcuGav == 1
            cQry += " AND SEPULT.U04_OCUPAG = 'S' "
        endIf
        
        // filtro para quadra
        if !Empty(cQuadra)
            cQry += " AND JAZIGO.U10_QUADRA IN " + FormatIn( AllTrim(cQuadra), ";" )
        endIf

        // filtro de modulo
        if !Empty(cModuloAte)
            cQry += "   AND JAZIGO.U10_MODULO BETWEEN '" + AllTrim(cModuloDe) + "' AND '" + AllTrim(cModuloAte) + "'"
        endIf

        // filtro de jazigo
        if !Empty(cJazigoAte)
            cQry += "   AND JAZIGO.U10_CODIGO BETWEEN '" + AllTrim(cJazigoDe) + "' AND '" + AllTrim(cJazigoAte) + "'"
        endIf

    EndIf

    cQry += " ORDER BY QUADRA ASC,
    cQry += "          MODULO ASC,
    cQry += "          JAZIGO ASC,
    cQry += "          GAVETA_UTILIZACAO ASC

    MemoWrite("c:\temp\RCPGR030.txt",cQry)

    cQry := Changequery(cQry)
    TcQuery cQry NEW ALIAS "TRBEND"

    TRBEND->(dbEval({|| nCont++}))
    TRBEND->(DbGoTop())

    oReport:SetMeter(nCont)

    nJazOcup	:= 0
    nJazEnde	:= 0
    nJazLivre	:= 0
    nAberto		:= 0

    // vou percorrer os registros de endereco
    While !oReport:Cancel() .And. TRBEND->(!EOF())

        oEnderecos:Init()
        oReport:IncMeter()

        If oReport:Cancel()
            Exit
        EndIf

        // pego a chave do registro atual
        cAtuChave := TRBEND->QUADRA+TRBEND->MODULO+TRBEND->JAZIGO

        // faco a impressao do enderecamento
        oEnderecos:Cell("QUADRA"):SetValue(TRBEND->QUADRA)
        oEnderecos:Cell("DESC_QUADRA"):SetValue(TRBEND->DESC_QUADRA)
        oEnderecos:Cell("MODULO"):SetValue(TRBEND->MODULO)
        oEnderecos:Cell("JAZIGO"):SetValue(TRBEND->JAZIGO)        
        oEnderecos:Cell("GAVETA_UTILIZACAO"):SetValue(TRBEND->GAVETA_UTILIZACAO)
        oEnderecos:Cell("DATA_UTILIZACAO"):SetValue(Stod(TRBEND->DATA_UTILIZACAO))
        oEnderecos:Cell("OCUPAG"):SetValue(iif(TRBEND->OCUPAG=="S","SIM", "NÃO"))
        oEnderecos:Cell("CONTRATO"):SetValue(TRBEND->CONTRATO)
        oEnderecos:Cell("QUEM_UTILIZOU"):SetValue(TRBEND->QUEM_UTILIZOU)
        oEnderecos:PrintLine()

        //===========================================
        // TOTALIZAODRES DE JAZIGOS
        //===========================================
        If AllTrim(TRBEND->TITULO) == "ENDOCUPADOS" .And. cAntChave <> cAtuChave // jazigos ocupados

            nJazOcup++ // variavel contado

            // guardo o valor da chave atual, para comparar com o proximo registro
            cAntChave   := cAtuChave

        ElseIf AllTrim(TRBEND->TITULO) == "ENDVAZIOS" .And. cAntChave <> cAtuChave // jazigos enderecadOS

            nJazEnde++ // variavel contado

            // guardo o valor da chave atual, para comparar com o proximo registro
            cAntChave   := cAtuChave

        ElseIf AllTrim(TRBEND->TITULO) == "LIVRES" .And. cAntChave <> cAtuChave // jazigos enderecad

            nJazLivre++ // variavel contado

            // guardo o valor da chave atual, para comparar com o proximo registro
            cAntChave   := cAtuChave

        EndIf

        oReport:SkipLine()

        TRBEND->(DbSkip())

    EndDo

    oEnderecos:Finish()

    oTotal:Init()
    oTotal:Cell("nJazOcup"):SetValue(nJazOcup)
    oTotal:Cell("nJazEnde"):SetValue(nJazEnde)
    oTotal:Cell("nJazLivre"):SetValue(nJazLivre)

    oTotal:PrintLine()
    oTotal:Finish()

    oTotal:SetPageBreak(.T.)

    // verifico se o alias esta em uso
    If Select("TRBEND") > 0
        TRBEND->( dbCloseArea() )
    EndIf

Return

/*/{Protheus.doc} AjustaSX1
Altero as informacoes do grupo de perguntas SX1
@author g.sampaio
@since 04/09/2019
@version P12
@param nulo
@return nulo
/*/

Static Function AjustaSX1( cPerg )

    Local aArea     := GetArea()
    Local aRegs     := {}

    Default cPerg   := ""

    // verifico se se foi preenchido a tabela
    If !Empty( cPerg )

        // parametros SX1
        aAdd(aRegs,{cPerg,'01','Quadra'                     ,'','','mv_ch1','C', 99                         , 0, 0,'G','','mv_par01','','','','','','U08MRK'})        
        aAdd(aRegs,{cPerg,'02','De Modulo'                  ,'','','mv_ch2','C', TamSX3("U10_MODULO")[1]    , 0, 0,'G','','mv_par02','','','','','',''})
        aAdd(aRegs,{cPerg,'03','Ate Modulo'                 ,'','','mv_ch3','C', TamSX3("U10_MODULO")[1]    , 0, 0,'G','','mv_par03','','','','','',''})
        aAdd(aRegs,{cPerg,'04','De Jazigo'                  ,'','','mv_ch4','C', TamSX3("U10_CODIGO")[1]    , 0, 0,'G','','mv_par04','','','','','',''})        
        aAdd(aRegs,{cPerg,'05','Ate Jazigo'                 ,'','','mv_ch5','C', TamSX3("U10_CODIGO")[1]    , 0, 0,'G','','mv_par05','','','','','',''})        
        aAdd(aRegs,{cPerg,'06','Situacao '                  ,'','','mv_ch6','N', 01                         , 0, 0,'N','','mv_par06','1=Ambos','2=End.Ocupado','3=End.Vazio','4=Livres','',''})
        aAdd(aRegs,{cPerg,'07','Considera Gaveta Ocupada? ' ,'','','mv_ch7','N', 01                         , 0, 0,'N','','mv_par07','1=Sim','2=Não','','','',''})

        // cria os dados da SX1
        U_CriaSX1( aRegs )

    EndIf

    RestArea( aArea )

Return( Nil )
