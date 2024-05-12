#Include "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} RUTILE022
Fonte responsavel pela classe ImagemContratos
@type function
@version 1.0
@author nata.queiroz
@since 23/11/2020
/*/
User Function RUTILE22
Return

/*/{Protheus.doc} ImagemContratos
Classe que realiza a gravacao de imagens no Repositorio de Objetos
@author Raphael Martins
@since 20/01/2020
@version P12
@param nulo
@return nulo
/*/
Class ImagemContratos

    Data aHeadOut
    Data nTimeOut

    Method New() Constructor            //Método Construtor
    Method IntegraImagens()             //Método que consulta imagens pendentes de integracao
    Method GravaBancoConhecimento()     //Metodo para gravar imagem em banco de conhecimento
    Method RetProximoCodigo()           //Metodo para retornar o proximo codigo do banco de conhecimento

EndClass

/*/{Protheus.doc} ImagemContratos:New
Construtor da Classe de Integracao das imagens
@author Raphael Martins Garcia
@since 20/01/2020
@version P12
@param nulo
@return nulo
/*/
Method New() Class ImagemContratos

	Self:aHeadOut		:= {}
	Self:nTimeOut		:= 15

Return()

/*/{Protheus.doc} ImagemContratos:IntegraImagens
Metodo para realizar o get no endereco e retornar imagens Pendentes de Sincronizacao
@author Raphael Martins 
@since 20/01/2020
@version P12
@param Filtro
@return nulo
/*/

Method IntegraImagens(nRegistro,cIdMobile,cEntidade,cEndereco,cIdImagem,cDescImagem,cContrato,cErroAnx) Class ImagemContratos

Local aArea             := GetArea()
Local aHeader           := {}
Local lRet              := .T.
Local lExist            := .F.
Local nExclui           := 0
Local oRest             := NIL
Local cDirPadrao	    := SuperGetMv("MV_XDIRPAD",,"\Integracao_virtus\")
Local lGravaFilAC9      := SuperGetMv("MV_XGRVENT",,.T.)
Local cFile             := ""
Local cExten            := ""
Local cCodObj           := ""
Local cChaveEntidade    := ""
Local nStart            := Seconds()

// INSTANCIA O CLIENTE REST
oRest := FwRest():New(cEndereco)
oRest:SetPath("")

// ENVIA A REQUISIÇÃO E VALIDA O RESULTADO
If (oRest:Get(aHeader))

    //Cria diretorio para integracao virtus se nao existir
	if !ExistDir(cDirPadrao)
	
    	MakeDir(cDirPadrao)
	
    endif

    //Verifico se ja exsite arquivo
	lExist := File(cDirPadrao + cIdImagem )

    If lExist

        //excluo o arquivo ja existente
	    nExclui := FErase(cDirPadrao + cIdImagem)

		If nExclui <> 0

            cErroAnx := "ERRO AO EXCLUIR ARQUIVO"

            FwLogMsg("INFO",, "REST", FunName(), "", "01", cErroAnx , 0, (Seconds() - nStart), {})
            lRet := .F.
		
        Endif
    
    Endif

    if lRet 

        nHandle := FCREATE(cDirPadrao + cIdImagem)

        //valido se arquivo foi criado com sucesso
		if nHandle = -1
            
            cErroAnx := "ERRO AO CRIAR O ARQUIVO"
            
            FwLogMsg("INFO",, "REST", FunName(), "", "01", cErroAnx  , 0, (Seconds() - nStart), {})

		else
            
            //gravo a imagem no arquivo criado
			FWrite(nHandle,oRest:GetResult())
			FClose(nHandle)

            //Grava o objeto no Banco de Conhecimento.
            lRet := ::GravaBancoConhecimento(cDirPadrao+cIdImagem) 
            
            If lRet

				SplitPath(cDirPadrao + cIdImagem,,,@cFile,@cExten)

				DbSelectArea("ACB")
				ACB->(DbSetOrder(2)) //ACB_FILIAL+ACB_OBJETO

				If !ACB->(DbSeek(xFilial("ACB")+cFile+cExten))

					//Inclui registro no banco de conhecimento
					cCodObj := ::RetProximoCodigo()

					RecLock("ACB",.T.)
					ACB->ACB_FILIAL := xFilial("ACB")
					ACB->ACB_CODOBJ := cCodObj
					ACB->ACB_OBJETO	:= cFile+cExten
					ACB->ACB_DESCRI	:= Upper(cDescImagem)
					ACB->(MsUnLock())

					ConfirmSx8()
				Else
					cCodObj := ACB->ACB_CODOBJ
				Endif

                //valido se grava a chave completa da entidade na AC9
                if lGravaFilAC9
                    cChaveEntidade := xFilial(cEntidade)+cContrato
                else
                    cChaveEntidade := cContrato
                endif

				//Inclui amarração entre registro do banco e entidade
				RecLock("AC9",.T.)
				AC9->AC9_FILIAL	:= xFilial("AC9")
				AC9->AC9_FILENT	:= xFilial(cEntidade)
				AC9->AC9_ENTIDA	:= cEntidade
				AC9->AC9_CODENT	:= cChaveEntidade
				AC9->AC9_CODOBJ	:= cCodObj
				AC9->(MsUnLock())
				
				//apaga arquivo da pasta temporaria
				FErase(cDirPadrao + cIdImagem)
			Else 
                
                cErroAnx := "ERRO AO TRANSFERIR O ARQUIVO PARA O BANCO DE CONHECIMENTO"

                FwLogMsg("INFO",, "REST", FunName(), "", "01", cArqAnx , 0, (Seconds() - nStart), {})

            Endif

        endif

    endif

else

    lRet := .F.
    
    cErroAnx := oRest:GetLastError()

    cErroAnx := "NÃO FOI POSSIVEL CONECTAR A URL DO REPOSITORIO"

    FwLogMsg("INFO",, "REST", FunName(), "", "01", cErroAnx , 0, (Seconds() - nStart), {})

endif

RestArea(aArea)

Return()

/*/{Protheus.doc} ImagemContratos:GravaBancoConhecimento
Metodo para gravar imagem sincronizada no banco de conhecimento
do Protheus
@author Raphael Martins 
@since 20/01/2020
@version P12
@param Filtro
@return nulo
/*/
Method GravaBancoConhecimento(cGetFile) Class ImagemContratos

Local cDirDocs  := ""
Local cFile     := ""
Local cExten    := ""
Local cNameTerm := ""
Local lRet      := .T.

cGetFile 	:= AllTrim( cGetFile )

SplitPath( cGetFile, , , @cFile, @cExten )

cNameTerm := Upper(AllTrim(cFile+cExten))

If FindFunction( "MsMultDir" ) .And. MsMultDir()
    cDirDocs := MsRetPath( cNameTerm )
Else
    cDirDocs := MsDocPath()
Endif

//copia arquivo para o diretorio do banco de conhecimento
__CopyFile( cGetFile, cDirDocs + "\" + cNameTerm )

lRet := File( cDirDocs + "\" + cNameTerm )

If !lRet
    
    //////////////////////////////////////////////////////////
    // Caso exista, exclui o arquivo com o nome anterior  ///
    /////////////////////////////////////////////////////////
    FErase( cDirDocs + "\" + cNameTerm )

    Help( " ", 1, "FT340CPT2S" ) //Nao foi possivel transferir o arquivo para o banco de conhecimento !

EndIf

Return(lRet)

/*/{Protheus.doc} ImagemContratos:RetProximoCodigo
Metodo para retornar o proximo codigo do banco de conhecimento
@author Raphael Martins 
@since 20/01/2020
@version P12
@param Filtro
@return nulo
/*/
Method RetProximoCodigo() Class ImagemContratos

Local cQSEQ 	:= ""
Local cProximo	:= ""

cQSEQ := " SELECT"
cQSEQ += "	MAX(ACB_CODOBJ) CODPROXIMO"
cQSEQ += "	FROM " + RETSQLNAME("ACB")
cQSEQ += "	WHERE D_E_L_E_T_ = ' '""

cQSEQ := ChangeQuery(cQSEQ)

if Select("QPRO") > 1
    QPRO->(DbCloseArea())
endif

TcQuery cQSEQ New alias "QPRO"

FreeUsedCode()

cProximo := Soma1(QPRO->CODPROXIMO)

// se ja estiver em uso eu pego um novo numero para o banco de conhecimento
While !MayIUseCode("ACB"+xFilial("ACB")+cProximo )
    cProximo := Soma1(cProximo)
EndDo

Return(cProximo)
