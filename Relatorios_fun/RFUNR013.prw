#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "protheus.ch"
#INCLUDE "TopConn.ch"

/*/{Protheus.doc} RFUNR013
Rotina de Processamento de Importacoes 
de Convalescente
@author Leandro Rodrigues
@since 23/09/2019
@version P12
@param Nao recebe parametros
@return nulo
/*/

#DEFINE NOME_EMP     06
#DEFINE REC_EMP      12
#DEFINE CGC_EMP      18

User Function RFUNR013()

Local oPrinter
Local lAdjustToLegacy   := .T.
Local lDisableSetup     := .F.
Local cLocal            := "\spool"
Local cNome             := "Contrato_Convalescente.rel"
Local lPreview          := .T.
Local aEmpresa          := FWArrFilAtu()
Local nLargPagina       := 0

//Fontes utilizadas no relatorio 
Static oFont14N	    := TFont():New("MS Sans Serif",,014,,.T.,,,,,.F.,.F.)
Static oFont12N	    := TFont():New("MS Sans Serif",,012,,.T.,,,,,.F.,.F.)
Static oFont12	    := TFont():New("MS Sans Serif",,012,,.F.,,,,,.F.,.F.)
Static oFont10	    := TFont():New("MS Sans Serif",,010,,.F.,,,,,.F.,.F.)

//Posiciono na empresa
SM0->( DbGoto( aEmpresa[REC_EMP] ))

oPrinter := FWMSPrinter():New(cNome, IMP_SPOOL, lAdjustToLegacy,cLocal, lDisableSetup, , , , , , .F., )

//Seta a resolucao
oPrinter:SetResolution(72)

//Define orientacao do relatorio
oPrinter:SetPortrait()

//Define papel que sera impresso
oPrinter:SetPaperSize(DMPAPER_A4) 

//Define as margens do relatorio
//nEsquerda, nSuperior, nDireita, nInferior
oPrinter:SetMargin(30,30,30,30) 

//Inicia a impressao de uma nova pagina
oPrinter:StartPage()

//Pego largura da pagina
nLargPagina := oPrinter:nPageWidth - 150

//############################################################################
//                      Cabecalho do relatorio                        
//############################################################################
Cabecalho(oPrinter,nLargPagina)

//############################################################################
//                      Imprime Dados Relatorio                           
//############################################################################
Imprime(oPrinter,nLargPagina,aEmpresa)

//Finalizo a impressao
oPrinter:EndPage()

If lPreview
	oPrinter:Preview()
EndIf
	
Return 

/*/{Protheus.doc} RFUNR013
Imprime Cabecalho
@author Leandro Rodrigues
@since 06/11/2019
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function Cabecalho(oPrinter,nLargPagina,cNomeImg)

Local cNomeImg  := SuperGetMv("MV_XIMGCON",,"\logo.png")

//Imprime logo no relatorio
oPrinter:SayBitmap( 075, 10, cNomeImg, 200, 200)

oPrinter:SayAlign( 065,030,UPPER(Alltrim(FWFilialName())),oFont14N,nLargPagina, 200, CLR_BLACK, 2, 2 )  
oPrinter:SayAlign( 100,030,Alltrim(SM0->M0_ENDCOB) +" - " +Alltrim(SM0->M0_BAIRCOB) ,oFont10,nLargPagina, 200, CLR_BLACK, 2, 2 )  
oPrinter:SayAlign( 130,030,Alltrim(SM0->M0_TEL) ,oFont10,nLargPagina, 200, CLR_BLACK, 2, 2 )

//Imprime titulo do relatorio 
oPrinter:SayAlign( 210,030,"Contrato de Cessão de Uso de Equipamentos Especiais",oFont14N,nLargPagina, 200, CLR_BLACK, 02, 2 )

//Imprime o Numero do contrato
oPrinter:SayAlign( 270,030,"Nº " + UJH->UJH_CODIGO ,oFont14N,nLargPagina, 200, CLR_BLACK, 2, 2 )

//Desenha uma linha na tela
oPrinter:Line( 330, 10, 330, nLargPagina,, "-6")

//Desenha uma linha na tela
oPrinter:Line( 460, 10, 460, nLargPagina,, "-6")

Return 

/*/{Protheus.doc} RFUNR013
Imprime dados do relatorio.
@author Leandro Rodrigues
@since 06/11/2019
@version P12
@param Nao recebe parametros
@return nulo
/*/

Static Function Imprime(oPrinter,nLargPagina,aEmpresa)

Local nLin          := 1
Local nValorBem     := 0
Local dPrevisaoRet  := CTOD("")
Local nCarencia     := SuperGetMv("MV_XCARPRI",,60)  
Local lConsCarencia := SuperGetMv("MV_XCONCAR",,.T.) //Considera a carencia para inserir como previsao de devolucao

//Cedente
oPrinter:Say( 510, 030, "Cedente: ", oFont12N, 1400, CLR_BLACK)
oPrinter:Say( 510, 320, UPPER(Alltrim(FWFilialName())), oFont12, 1400, CLR_BLACK)

//CNPJ
oPrinter:Say( 510, 1050, "CNPJ: ", oFont12N, 1400, CLR_BLACK)
oPrinter:Say( 510, 1340, Alltrim(aEmpresa[18]), oFont12, 1400, CLR_BLACK)


SF2->(DbSetOrder(1))
SF4->(DbSetOrder(1))

//Posiciono no Contrato
If UF2->(DbSeek(xFilial("UF2") +UJH->UJH_CONTRA ))

    if SA1->(DbSeek(xFilial("SA1") + UF2->UF2_CLIENT + UF2->UF2_LOJA ))

        //Posiciono no beneficiario
        If UF4->(DbSeek(xFilial("UF4") +UJH->UJH_CONTRA + UJH->UJH_CODBEN ))
            
            oPrinter:Say( 560, 030, "Cessionário: ", oFont12N, 1400, CLR_BLACK)
            oPrinter:Say( 560, 320, Alltrim(SA1->A1_NOME), oFont12, 1400, CLR_BLACK)

            oPrinter:Say( 610, 030, "CPF: ", oFont12N, 1400, CLR_BLACK)
            oPrinter:Say( 610, 320, Alltrim(SA1->A1_CGC), oFont12, 1400, CLR_BLACK)
            
            oPrinter:Say( 660, 030, "Endereco: ", oFont12N, 1400, CLR_BLACK)
            oPrinter:Say( 660, 320, Alltrim(SA1->A1_END), oFont12, 1400, CLR_BLACK)

            oPrinter:Say( 710, 030, "CEP: ", oFont12N, 1400, CLR_BLACK)
            oPrinter:Say( 710, 320, Alltrim(SA1->A1_CEP), oFont12, 1400, CLR_BLACK)

            oPrinter:Say( 760, 030, "Cidade: ", oFont12N, 1400, CLR_BLACK)
            oPrinter:Say( 760, 320,  Alltrim(SA1->A1_MUN), oFont12, 1400, CLR_BLACK)

            oPrinter:Say( 560, 1050, "Beneficiario: ", oFont12N, 1400, CLR_BLACK)
            oPrinter:Say( 560, 1340, Alltrim(UF4->UF4_NOME), oFont12, 1400, CLR_BLACK)

            oPrinter:Say( 610, 1050, "RG: ", oFont12N, 1400, CLR_BLACK)
            oPrinter:Say( 610, 1340, Alltrim(SA1->A1_RG), oFont12, 1400, CLR_BLACK)

            oPrinter:Say( 660, 1050, "Bairro: ", oFont12N, 1400, CLR_BLACK)
            oPrinter:Say( 660, 1340, Alltrim(SA1->A1_BAIRRO), oFont12, 1400, CLR_BLACK)

            oPrinter:Say( 710, 1050, "Telefone: ", oFont12N, 1400, CLR_BLACK)
            oPrinter:Say( 710, 1340, "(" + Alltrim(SA1->A1_DDD) +") "+  Alltrim(SA1->A1_TEL), oFont12, 1400, CLR_BLACK)    
        
            oPrinter:Say( 760, 1050, "Estado: ", oFont12N, 1400, CLR_BLACK)
            oPrinter:Say( 760, 1340,  Alltrim(SA1->A1_EST), oFont12, 1400, CLR_BLACK) 

        Endif

    Endif

Endif

//Desenha uma linha na tela
oPrinter:Line( 810, 10, 810, nLargPagina,, "-4")

UJI->(DbSetOrder(1))

//############################################################################
//                      Imprime Itens Convalescente                               
//############################################################################

//Posiciono no item da locacao
If UJI->(DbSeek(xFilial("UJI")+ UJH->UJH_CODIGO ))

    oPrinter:Say( 860,  030, "Equipamento"      , oFont12N, 1400, CLR_BLACK)
    oPrinter:Say( 860,  320, "Descrição"        , oFont12N, 1400, CLR_BLACK)
    oPrinter:Say( 860, 1050, "Retirada"         , oFont12N, 1400, CLR_BLACK)
    oPrinter:Say( 860, 1350, "Prev.Devolução"   , oFont12N, 1400, CLR_BLACK)
    oPrinter:Say( 860, 1800, "Vlr.Locação"      , oFont12N, 1400, CLR_BLACK)

    oPrinter:Line( 890, 10, 890, nLargPagina,, "-4")
    

    //valido se considera a carencia ou a ultima parcela para provisionar a devolucao
    if !lConsCarencia
        //Pego o vencimento da ultima parcela
        dPrevisaoRet := LastParcela()
    
    endif
   

    //Varivael para controlar linha de impressao
    nLin := 890

    While UJI->(!EOF()) ;
        .AND. UJI->UJI_FILIAL+UJI->UJI_CODIGO == UJH->UJH_FILIAL+UJH->UJH_CODIGO
      
        nLin += 050

         //Pego o valor do bem
        nValorBem += ValorBem(  UJI->UJI_CHAPA )
        
        //retorna a previsao de devolucao
        if lConsCarencia
            
            dPrevisaoRet := DaySum(UJI->UJI_DATAIN,nCarencia)

        endif

        //Valido se equipamento ja retornou
        if Empty(UJI->UJI_DATARE) 
        
            oPrinter:Say( nLin,  030, UJI->UJI_CHAPA                 , oFont12, 1400, CLR_BLACK)
            oPrinter:Say( nLin,  320, UJI->UJI_DESC                  , oFont12, 1400, CLR_BLACK)
            oPrinter:Say( nLin, 1050, dToc(UJI->UJI_DATAIN)          , oFont12, 1400, CLR_BLACK)
            oPrinter:Say( nLin, 1350, dToc(dPrevisaoRet)             , oFont12, 1400, CLR_BLACK)
            
            
            oPrinter:Say( nLin, 1800, Transform(UJI->UJI_VLTOTA,PesqPict("UJI","UJI_VLTOTA")), oFont12, 1400, CLR_BLACK)
        
        endif

        UJI->(DbSkip())
    EndDo
    
endif

nLin += 50 

//Imprime linha no relatorio
oPrinter:Line( nLin, 10, nLin, nLargPagina,, "-4")

//############################################################################
//                      Imprime Cláusulas contratuais                            
//############################################################################

nLin += 50
oPrinter:Say( nLin,  030, "Cláusulas Contratuais "      , oFont12N, 1400, CLR_BLACK)

nLin += 100
oPrinter:SayAlign( nLin,030,"Artigo 1º" ,oFont12,200, 200, CLR_BLACK, 0, 2 )
oPrinter:SayAlign( nLin,250,"O equipamento acima mencionado é de propriedade da CEDENTE a "+UPPER(Alltrim(FWFilialName())) +"." ,oFont12,nLargPagina - 250, 200, CLR_BLACK, 0, 2 )

nLin += 100
oPrinter:SayAlign( nLin-25,030,"Artigo 2º" ,oFont12,200, 200, CLR_BLACK, 0, 2 )
oPrinter:SayAlign( nLin,250,"O CESSIONÁRIO (A) poderá retirar o equipamento para seu  uso  ou de seus  beneficiários pelo tempo e condições descritas neste instrumento. " ,oFont12,nLargPagina - 250, 200, CLR_BLACK, 0, 2 )

nLin += 100
oPrinter:SayAlign( nLin-25,030,"Artigo 3º" ,oFont12,200, 200, CLR_BLACK, 0, 2 )
oPrinter:SayAlign( nLin,250,"Os equipamentos poderão  ser  utilizados  exclusivamente  pelos beneficiários do contrato de inscrição acima mencionada." ,oFont12,nLargPagina - 250, 200, CLR_BLACK, 0, 2 )

nLin += 100
oPrinter:SayAlign( nLin-25,030,"Artigo 4º" ,oFont12,200, 200, CLR_BLACK, 0, 2 )
oPrinter:SayAlign( nLin,250,"Os equipamentos cedidos sem qualquer custo pelo período de até 60 (Sessenta) dias, desde que haja solicitação médica especializado" ,oFont12,nLargPagina - 250, 200, CLR_BLACK, 0, 2 )

nLin += 100
oPrinter:SayAlign( nLin-25,030,"Artigo 5º" ,oFont12,200, 200, CLR_BLACK, 0, 2 )
oPrinter:SayAlign( nLin,250,"Os custos de manutenção a serem cobrados mensalmente serão baseados na tabela de valores existente na "+UPPER(Alltrim(FWFilialName()))+". " ,oFont12,nLargPagina - 250, 200, CLR_BLACK, 0, 2 )

nLin += 100
oPrinter:SayAlign( nLin-25,030,"Artigo 6º" ,oFont12,200, 200, CLR_BLACK, 0, 2 )
oPrinter:SayAlign( nLin,250,"O (A) CESSIONARIO (A) poderá optar pela aquisição definitiva do bem, pelo valor de custo conseguido mediante negociação do cedente e o fornecedor do equipamento. " ,oFont12,nLargPagina - 250, 200, CLR_BLACK, 0, 2 )

nLin += 100
oPrinter:SayAlign( nLin-25,030,"Artigo 7º" ,oFont12,200, 200, CLR_BLACK, 0, 2 )
oPrinter:SayAlign( nLin,250,"O (A) CESSIONÁRIO se responsabiliza pelos danos causados ao equipamento, e a devolve-lo no prazo estipulado em perfeita condições de uso e sem alteração das características do mesmo.  " ,oFont12,nLargPagina - 250, 200, CLR_BLACK, 0, 2 )

nLin += 100
oPrinter:SayAlign( nLin-25,030,"Artigo 8º" ,oFont12,200, 200, CLR_BLACK, 0, 2 )
oPrinter:SayAlign( nLin,250,"A CEDENTE não se responsabiliza por qualquer dano ou defeito negativo que a utilização do equipamento possa causar ao usuário." ,oFont12,nLargPagina - 250 , 200, CLR_BLACK, 0, 2 )

nLin += 100
oPrinter:SayAlign( nLin-25,030,"Artigo 9º" ,oFont12,200, 200, CLR_BLACK, 0, 2 )
oPrinter:SayAlign( nLin,250,"Fica ao associado à responsabilidade de pegar o equipamento na matriz ou em alguma das filiais e também para devolvê-lo " ,oFont12,nLargPagina - 250, 200, CLR_BLACK, 0, 2 )

//############################################################################
//                      Imprime local de assinatura                            
//############################################################################

nLin += 120
oPrinter:SayAlign( nLin,030, Alltrim(SM0->M0_CIDCOB) + "/" + Alltrim(SM0->M0_ESTCOB) +","+ U_DATAEXTENSO(UJH->UJH_DATAIN)  ,oFont12,nLargPagina - 250, 200, CLR_BLACK, 2, 2 )

nLin += 120
oPrinter:SayAlign( nLin     ,080, Replicate("_",40)                ,oFont12,800, 200, CLR_BLACK, 0, 2 )
oPrinter:SayAlign( nLin+30  ,080, UPPER(Alltrim(FWFilialName()))   ,oFont10,800, 200, CLR_BLACK, 2, 2 )


oPrinter:SayAlign( nLin     ,1360, Replicate("_",40)                ,oFont12,800, 200, CLR_BLACK, 0, 2 )
oPrinter:SayAlign( nLin+30  ,1360, UPPER(Alltrim(SA1->A1_NOME))     ,oFont10,800, 200, CLR_BLACK, 2, 2 )

//############################################################################
//                      Imprime Box de promissoria                            
//############################################################################
nLin += 300
//Box Macro
oPrinter:Box( nLin, 090,nLin+550, nLargPagina - 100, "-4")

nLin += 20

//Box N Contrato
oPrinter:Box( nLin, 150,nLin+70, 550, "-4")
oPrinter:Say( nLin+40, 180, "Nº "+ UJH->UJH_CODIGO , oFont12n, 500, CLR_BLACK)

//Box Valor Equipamento
oPrinter:Box( nLin      , 1500,nLin+70, 2100, "-4")
oPrinter:Say( nLin+40   , 1550, "R$ "       , oFont12n, 1400, CLR_BLACK)
oPrinter:Say( nLin+40   , 1700, Transform(nValorBem,"@E 99,999,999.99")   , oFont12n, 1400, CLR_BLACK)

nLin += 60
oPrinter:Say( nLin,  600, "Vencimento, "+  U_DATAEXTENSO(UJH->UJH_DATAIN)  , oFont12n, 1400, CLR_BLACK)


nLin += 60
oPrinter:Say( nLin,  150, "A "+Alltrim(SA1->A1_NOME) , oFont12, 1400, CLR_BLACK)

nLin += 50
oPrinter:Say( nLin,  150, "pagarei à "+ UPPER(Alltrim(FWFilialName())) + " CGC: "+ Alltrim(aEmpresa[18]) , oFont12, 1400, CLR_BLACK)

nLin += 50
oPrinter:Say( nLin,  150, "por esta única via de NOTA PROMISSÓRIA OU A SUA ORDEM, a Quantia De:" , oFont12, 1400, CLR_BLACK)

nLin += 50
oPrinter:Box( nLin    , 150,nLin+70, 1510, "-4")
oPrinter:Say( nLin+40 , 160,Extenso(nValorBem),  oFont10, 1400, CLR_BLACK)
oPrinter:SayAlign(nLin-130,1550,"EM MOEDA CORRENTE DESTE PAIS" ,oFont10,300, 200, CLR_BLACK, 0, 2 )

nLin += 110
oPrinter:Say( nLin, 150, "Pagável em " + Alltrim(SM0->M0_CIDCOB) + "/" + Alltrim(SM0->M0_ESTCOB) , oFont12, 1400, CLR_BLACK)

nLin += 40
oPrinter:Say( nLin, 150    , "EMITENTE "                   , oFont12n, 400, CLR_BLACK)
oPrinter:Say( nLin, 350    , UPPER(Alltrim(SA1->A1_NOME))   , oFont12, 400, CLR_BLACK)

nLin += 40
oPrinter:Say( nLin, 150    , "CPF "       , oFont12n, 400, CLR_BLACK)
oPrinter:Say( nLin, 350    , SA1->A1_CGC   , oFont12 , 400, CLR_BLACK)

//############################################################################
//                      Imprime rodape                          
//############################################################################
nLin -= 10
oPrinter:Say( nLin -10, 1200, Replicate("_",40), oFont12n, 400, CLR_BLACK)

nLin += 50
oPrinter:Say( nLin, 150    , "ENDEREÇO "            , oFont12n, 400, CLR_BLACK)
oPrinter:Say( nLin, 350    , Alltrim(SA1->A1_END)   , oFont12 , 400, CLR_BLACK)

nLin += 10
oPrinter:Say( nLin, 1200    , Replicate("_",40), oFont12n, 400, CLR_BLACK)

Return 

/*/{Protheus.doc} RFUNR013
Retorna data de vencimento da ultima 
parcela do ciclo ativo de Convalescente
@author Leandro Rodrigues
@since 06/11/2019
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function LastParcela()

Local cQry  := ""
Local cTipo := SuperGetMv("MV_XTIPOCV",,"EQ")

cQry:= " SELECT" 
cQry+= "     TOP 1 E1_VENCTO" 
cQry+= " FROM "+ RETSQLNAME("SE1") + " E1"
cQry+= " WHERE E1.D_E_L_E_T_= ' '"
cQry+= "    AND E1_FILIAL  = '" + xFilial("SE1")  + "'"
cQry+= "    AND E1_XCONCTR = '" + UJH->UJH_CODIGO + "'"
cQry+= "    AND E1_TIPO    = '" + cTipo + "'"
cQry+= " ORDER BY E1_VENCTO DESC"

cQry := ChangeQuery(cQry) 

If Select("QSE1") > 1
    QSE1->(DbCloseArea())
Endif

TcQuery cQry New Alias "QSE1"


Return STOD(QSE1->E1_VENCTO)

/*/{Protheus.doc} RFUNR013
Retorna valor do equipamento na tabela de preco
@author Leandro Rodrigues
@since 06/11/2019
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function ValorBem(cChapa)

Local nVlrEquipa   := 0 
Local cTabPreco    := SuperGetMv("MV_XTABEQP")

SN1->(DbSetOrder(2)) 
SB1->(DbSetOrder(1)) 

//Posiciono no Ativo para pegar o codigo do produto vinculado
If SN1->(DbSeek(xFilial("SN1") + cChapa ))

    //Posiciono no produto
	If SB1->(DbSeek(xFilial("SB1")+SN1->N1_PRODUTO))
        
        nVlrEqui:= U_RetPrecoVenda(cTabPreco,SB1->B1_COD)

    endif
endif

Return nVlrEqui
