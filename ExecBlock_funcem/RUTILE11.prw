#include "protheus.ch"
#include "fwmvcdef.ch"
#include "topconn.ch"
#include "tbiconn.ch"

#DEFINE TIT_NUM		1	//Nï¿½mero
#DEFINE TIT_PARC	2	//Parcela
#DEFINE TIT_VENCTO	3	//Data vencimento
#DEFINE TIT_VALOR	4	//Valor
#DEFINE TIT_MULTA	5	//Multa
#DEFINE TIT_JUROS	6	//Juros
#DEFINE TIT_DESC	7	//Desconto
#DEFINE TIT_RECEB	8	//Valor recebido
#DEFINE TIT_FPAGTO	9	//Forma de pagamento
#DEFINE TIT_TROCO	10	//Valor troco


/*/{Protheus.doc} RUTILE11
Importar do servidor Web contratos vendidos via app Mobile
@author TOTVS
@since 21/09/2018
@version P12
@param Nao recebe parametros
@return nulo.
/*/
User Function RUTILE11(aParam)
	Local cMessage := ""
	Local nStart := Seconds()
	
	Default aParam := {"01","010101"}

	If !IsBlind()
	
		If MsgYesNo("Confirma integração de dados de venda de contratos?")

			//-- Bloqueia rotina para apenas uma execução por vez
			//-- Criação de semáforo no servidor de licenças
			//-- LockByName( cName, lEmpresa, lFilial, [ lMayIUseDisk ] ) --> lCreated
			If !LockByName("RUTILE11", .F., .T.)
				MsgAlert("[RUTILE11]["+ cFilAnt +"] Existe um JOB ativo no momento. Aguarde...")

				Return
			EndIf

			//-- Comando para o TopConnect alterar mensagem do Monitor --//
			FWMonitorMsg("RUTILE11: JOB CONTRATOS VIRTUS VENDA => " + cEmpAnt + "-" + cFilAnt)
	
			FWMsgRun(,{|oSay| Integrar(oSay)},'Aguarde','Realizando integração...')

			//-- Libera rotina para nova execução
			//-- Excluir semáforo
			//-- UnLockByName( cName, lEmpresa, lFilial, [ lMayIUseDisk ] ) --> Nil
			UnLockByName("RUTILE11", .F., .T.)
	
		EndIf
	
	Else
		
		FwLogMsg("INFO",, "REST", FunName(), "", "01", "INICIO DO PROCESSO DE INTEGRACAO DE CONTRATOS", 0, (nStart - Seconds()), {})
		FwLogMsg("INFO",, "REST", FunName(), "", "01",  "EMPRESA: " + Alltrim(aParam[1]) + " FILIAL: " + Alltrim(aParam[2]) , 0, (nStart - Seconds()), {})

		
		RESET ENVIRONMENT
		PREPARE ENVIRONMENT EMPRESA aParam[1] FILIAL aParam[2] TABLES "UF2"

		//-- Bloqueia rotina para apenas uma execução por vez
		//-- Criação de semáforo no servidor de licenças
		//-- LockByName( cName, lEmpresa, lFilial, [ lMayIUseDisk ] ) --> lCreated
		If !LockByName("RUTILE11", .F., .T.)
			cMessage := "[RUTILE11]["+ cFilAnt +"] Existe um JOB ativo no momento. Aguarde..."
			FwLogMsg("INFO",, "REST", FunName(), "", "01", cMessage, 0, (Seconds() - nStart), {})

			Return
		EndIf

		//-- Comando para o TopConnect alterar mensagem do Monitor --//
		FWMonitorMsg("RUTILE11: JOB CONTRATOS VIRTUS VENDA => " + cEmpAnt + "-" + cFilAnt)

		Integrar()

		//-- Libera rotina para nova execução
		//-- Excluir semáforo
		//-- UnLockByName( cName, lEmpresa, lFilial, [ lMayIUseDisk ] ) --> Nil
		UnLockByName("RUTILE11", .F., .T.)

	EndIf

	If !IsBlind()
		MsgInfo("Sincronização finalizada.","Atenção")
	Else
		FwLogMsg("INFO",, "REST", FunName(), "", "01", "Sincronização finalizada.", 0, (nStart - Seconds()), {})
	Endif

Return

/*****************************/
Static Function Integrar(oSay)
/*****************************/

	Local cHost			:= SuperGetMv("MV_XENHOST",.F.,"virtus-homolg.herokuapp.com")
	Local cChaveVirt	:= GetMv("MV_XKEYAPP")
	Local oRestCliente	:= NIL
	Local oRestContCem	:= NIL
	Local oRestContFun	:= NIL
	Local oDadosAdiant	:= NIL
	Local oDadosAdesao 	:= NIL
	Local oDadosRecor	:= NIL
	Local oVindi		:= NIL

	Local cTpIndice		:= SuperGetMv("MV_XINDMOB",.F.,"001")
	Local nC, nI, nJ, nX, nCont, nR, nAux, nF, nIt, nP

	Local nRecnoU00			:= 0
	Local nRecnoSA1			:= 0
	Local nQtdParcFun 		:= SuperGetmv('MV_XQTDPAR',,12)
	Local nDescontoAdesao	:= 0

	Local lGravou		:= .T.
	Local cIdMobile		:= ""
	Local cIdMobCli		:= ""
	Local lReceb
	Local cFPagto		:= ""
	Local cCodAdm		:= ""
	Local cCpfCnjp		:= ""
	Local cCliente		:= ""
	Local cLoja			:= ""
	Local nQtdParc		:= 0
	Local lContinua		:= .T.
	Local lAux			:= .T.
	Local lRet			:= .T.

	Local cNome			:= ""
	Local cTpPessoa		:= ""
	Local cNReduz		:= ""
	Local cEnd			:= ""
	Local cCompl		:= ""
	Local cPtoRef		:= ""
	Local cBairro		:= ""
	Local cProfissao	:= ""
	Local cEst			:= ""
	Local cCodMun		:= ""
	Local cCep			:= ""
	Local cDdd			:= ""
	Local cTel			:= ""
	Local cCgc			:= ""
	Local cRg			:= ""
	Local cInscEst		:= ""
	Local cInscMun		:= ""
	Local cEmail		:= ""
	Local cSequencia	:= ""
	Local cLoteBx		:= ""
	Local nTamMDNLt		:= TamSx3("MDN_LOTE")[1]

	Local cURLCem		:= SuperGetMv("MV_XRESCEM",.F.,"HTTPS://VIRTUS-HOMOLG.HEROKUAPP.COM/CONTRATOCEM")
	Local cURLFun		:= SuperGetMv("MV_XRESFUN",.F.,"HTTPS://VIRTUS-HOMOLG.HEROKUAPP.COM/CONTRATOFUN")
	Local nTimeOut		:= 120
	Local aHeadOut		:= {}
	Local cHeadRet		:= ""
	Local cPostRet		:= ""

	Local nRecnoU00
	Local nRecnoUF2

	Local aCabec		:= {}
	Local aAux			:= {}
	Local aAutorizados	:= {}
	Local aBeneficiarios:= {}
	Local aProdutos		:= {}
	Local aServiï¿½os		:= {}
	Local aFPagto		:= {}
	Local aTitulo		:= {}
	Local aArea			:= {}
	Local aAreaSA1		:= {}
	Local aAreaCC2		:= {}
	Local aMensagem		:= {}
	Local nTxManuCem	:= SuperGetMv("MV_XTXMOBC",.F.,100)
	Local nTxManuFun	:= SuperGetMv("MV_XTXMOBF",.F.,0)
	Local cQtdCttRet	:= SuperGetMv("MV_XQTDCTR",.F.,"2")
	Local aRetorno		:= {}

	Local lAltData		:= .F.
	Local dBkpData		:=  CToD("")

	Local nAuxQtd		:= 0
	Local nAuxTot		:= 0

	Local cNewEmp 		:= ""
	Local cNewFil		:= ""
	Local cLogError		:= ""
	Local cCelular		:= ""
	Local cDDDCel		:= ""
	Local cEstCivil		:= ""
	Local cPathImg		:= ""
	Local cIdImagem		:= ""
	Local cDescricao	:= ""

	Local dDataNasc		:= CTOD("")
	Local cCxVend		:= ""
	
	Local lCemIntegra	:= SuperGetMv("MV_XINTCEM",.F.,.F.)
	Local lFunIntegra	:= SuperGetMv("MV_XINTFUN",.F.,.T.)
	Local nOperCli		:= 3
	Local aParcEnt		:= {}
	Local nY			:= 1
	Local nZ			:= 1
	Local nStart		:= Seconds()

	Private cPrefCem	:= SuperGetMv("MV_XPREFCT",.F.,"CTR")
	Private cPrefFun	:= SuperGetMv("MV_XPREFUN",.F.,"FUN")

	Private cTipoCem	:= SuperGetMv("MV_XTIPOEN",.F.,"ENT")
	Private cTipoFun	:= SuperGetMv("MV_XTIPFUN",.F.,"AT")

	Private lImp		:= .T. //Compatibilidade com o Grid Beneficiï¿½rios

	oObjCli := Nil
	oObjCem := Nil
	oObjFun := Nil
	oObjRet := Nil

	//chave de autenticacao de integracacao com o Virtus App
	aadd(aHeadOut,"Content-Type:application/json")
	aadd(aHeadOut,"Authorization: " + cChaveVirt)

	// crio o objeto de integracao com a vindi
	oVindi := IntegraVindi():New()

	//Sincronizando contratos cemitï¿½rio
	/*
	Campos obrigatï¿½rios
	U00_PLANO 	- Plano
	U00_VENDED	- Vendedor
	U00_DATA	- Data
	U00_FAQUIS	- Forma de aquisiï¿½ï¿½o
	U00_CLIENT	- Cliente
	U00_LOJA	- Loja
	U00_QTDPAR	- Qtde. parcelas
	U00_INDICE	- ï¿½ndice
	*/
	
	//valido se a integracao do cemiterio esta ativa
	if lCemIntegra 
	
		oRestContCem := FWRest():New(cHost)
		oRestContCem:setPath("/contratocem/")
		
		lRet := oRestContCem:Get(aHeadOut)
		
		If lRet
	
			FWJsonDeserialize(oRestContCem:GetResult(),@oObjCem)
	
			For nC := 1 To Len(oObjCem:result)
	
				aCabec 			:= {}
				aAutorizados	:= {}
				aProdutos		:= {}
				aServicos		:= {}
				aParcEnt		:= {}
				aFPagto			:= {}
				aTitulo			:= {}
				lAltData		:= .F.
				lContinua		:= .T.
	
				if !IsBlind()
	
					oSay:cCaption := ("Sincronizando Contratos Cemiterio: " + cValToChar(nC) + " de: " + cValToChar( Len(oObjCem:result) ) + " ...")
					ProcessMessages()
	
				else
					
					FwLogMsg("INFO",, "REST", FunName(), "", "01", "Sincronizando Contratos Cemiterio: " + cValToChar(nC) + " de: " + cValToChar( Len(oObjCem:result) ) + " ...", 0, (nStart - Seconds()), {})
	
				endif
	
				//Verifica a empresa e filial do contrato
				If oObjCem:result[nC]:cnpj <> SM0->M0_CGC
	
					DbSelectArea("UJ3")
					UJ3->(DbSetOrder(2)) //UJ3_FILIAL+UJ3_CGC
	
					If UJ3->(DbSeek(xFilial("UJ3")+oObjCem:result[nC]:cnpj))
	
						cNewEmp := UJ3->UJ3_CODIGO
						cNewFil	:= UJ3->UJ3_CODFIL
	
						RpcSetType(3)
						Reset Environment
						RpcSetEnv(cNewEmp,cNewFil)
					Else
						lAux := .F.
					Endif
				Else
					DbSelectArea("UJ3")
					UJ3->(DbSetOrder(2)) //UJ3_FILIAL+UJ3_CGC
	
					If !UJ3->(DbSeek(xFilial("UJ3")+oObjCem:result[nC]:cnpj))
						lAux := .F.
					Endif
				Endif
	
				aArea			:= GetArea()
				aAreaSA1		:= SA1->(GetArea())
				aAreaCC2		:= CC2->(GetArea())
	
				If lAux //Posicinou numa empresa de integração
	
					//Verifica se a data da venda é inferior a data atual/sincronização, se sim, alteara a data do sistema
					If SToD(oObjCem:result[nC]:data) < dDataBase
						dBkpData	:= dDataBase
						dDataBase 	:= SToD(oObjCem:result[nC]:data)
						lAltData	:= .T.
					Endif
	
					cIdMobile 	:= oObjCem:result[nC]:_id
					lReceb		:= IIF(oObjCem:result[nC]:recebeu == "verdadeiro",.T.,.F.)
					cCpfCnjp	:= oObjCem:result[nC]:cpfcnpj
	
					DbSelectArea("U00")
					U00->(DbOrderNickName("IDMOBILE")) //U00_FILIAL+U00_IDMOBI
	
					If !U00->(DbSeek(xFilial("U00")+cIdMobile))
	
						DbSelectArea("SA1")
						SA1->(DbSetOrder(3)) //A1_FILIAL+A1_CGC
	
						
						If SA1->(DbSeek(xFilial("SA1")+cCpfCnjp)) //Novo cliente
							nOperCli := 4
						else
							nOperCli := 3
						endif
	
						//Cadastra Cliente
						oRestCliente := FWRest():New(cHost)
						oRestCliente:setPath("/cliente/"+cCpfCnjp+"")
	
						If oRestCliente:Get(aHeadOut)
	
							oObjCli := Nil
	
							FWJsonDeserialize(oRestCliente:GetResult(),@oObjCli)
	
							cNome		:= Alltrim(oObjCli:result:nome)
							cTpPessoa	:= oObjCli:result:tipopessoa
							cNReduz		:= Alltrim(oObjCli:result:nomereduzido)
							cEnd		:= oObjCli:result:endereco
							cCompl		:= oObjCli:result:complemento
							cPtoRef		:= oObjCli:result:pontoref
							cBairro		:= oObjCli:result:bairro
							cEst		:= oObjCli:result:estado
							cCodMun		:= PadL(oObjCli:result:municipio,TamSx3("A1_COD_MUN")[1],"0")
							cCep		:= oObjCli:result:cep
							cDdd		:= iif(!Empty(oObjCli:result:ddd),StrZero(Val(oObjCli:result:ddd),TamSx3("A1_DDD")[1]),"")
							cTel		:= oObjCli:result:tel
							cCgc		:= oObjCli:result:cpfcnpj
							cRg			:= oObjCli:result:rg
							cInscEst	:= oObjCli:result:inscestadual
							cInscMun	:= oObjCli:result:inscmunicipal
							cEmail		:= oObjCli:result:email
							cIdMobCli	:= oObjCli:result:_id
							cCelular	:= oObjCli:result:celular
							cDDDCel		:= oObjCli:result:dddcel
							dDataNasc	:= STOD(oObjCli:result:datanasc)
							cEstCivil	:= oObjCli:result:estadocivil
							cProfissao	:= oObjCli:result:profissao
								
							If CadCli(cNome,cTpPessoa,cNReduz,cEnd,cCompl,cPtoRef,cBairro,cEst,cCodMun,cCep,cDdd,cTel,cCgc,cRg,cInscEst,cInscMun,cEmail,cIdMobCli,cCelular,cDDDCel,dDataNasc,cEstCivil,cProfissao,@cLogError,nOperCli)
	
								cCliente 	:= SA1->A1_COD
								cLoja		:= SA1->A1_LOJA
								nRecnoSA1	:= SA1->(Recno())
							Else
								lContinua := .F.
							Endif
	
							//Inclui log da integração
							RecLock("U56",.T.)
							U56->U56_FILIAL := xFilial("U56")
							U56->U56_CODIGO	:= GetSX8Num("U56","U56_CODIGO")
							U56->U56_TABELA	:= "SA1"
							U56->U56_RECNO	:= nRecnoSA1
							U56->U56_JSON	:= oRestCliente:GetResult()
							U56->U56_RETORN	:= ""
							U56->U56_DATA	:= dDataBase
							U56->U56_HORA	:= Time()
							U56->U56_USER	:= cUserName
							U56->(MsUnlock())
	
							ConfirmSX8()
	
							FreeObj(oObjCli)
						Endif
						
						If lContinua
	
							AAdd(aCabec,{"U00_PLANO"	,oObjCem:result[nC]:plano})
							AAdd(aCabec,{"U00_VENDED"	,oObjCem:result[nC]:vendedor})
							AAdd(aCabec,{"U00_DATA"		,SToD(oObjCem:result[nC]:data)})
							AAdd(aCabec,{"U00_FAQUIS"	,oObjCem:result[nC]:faquisicao})
							AAdd(aCabec,{"U00_MIDIA"	,oObjCem:result[nC]:midia})
							AAdd(aCabec,{"U00_CLIENT"	,cCliente})
							AAdd(aCabec,{"U00_LOJA"		,cLoja})
							AAdd(aCabec,{"U00_DESCON"	,Val(oObjCem:result[nC]:valordesconto)})
							AAdd(aCabec,{"U00_VLRENT"	,Val(oObjCem:result[nC]:valorentrada)})
							AAdd(aCabec,{"U00_DTENTR"	,SToD(oObjCem:result[nC]:dataentrada)})
							AAdd(aCabec,{"U00_QTDPAR"	,Val(oObjCem:result[nC]:qtparcelas)})
							AAdd(aCabec,{"U00_PRIMVE"	,SToD(oObjCem:result[nC]:vencimento)})
							AAdd(aCabec,{"U00_INDICE"	,cTpIndice})
							AAdd(aCabec,{"U00_TXMANU"	,nTxManuCem})
							AAdd(aCabec,{"U00_IDMOBI"	,cIdMobile})
	
							DbSelectArea("SB1")
							SB1->(DbSetOrder(1)) //B1_FILIAL+B1_COD
	
							For nIt := 1 To Len(oObjCem:result[nC]:itens)
	
								If SB1->(DbSeek(xFilial("SB1")+oObjCem:result[nC]:itens[nIt]:item))
	
									aAux := {}
	
									If AllTrim(SB1->B1_TIPO) <> "SV" //Diferente de Serviço
										AAdd(aAux,{"U01_PRODUT"		,oObjCem:result[nC]:itens[nIt]:item})
										AAdd(aAux,{"U01_QUANT"		,Val(oObjCem:result[nC]:itens[nIt]:quantidade)})
										AAdd(aProdutos,aAux)
									Else
										AAdd(aAux,{"U37_SERVIC"		,oObjCem:result[nC]:itens[nIt]:item})
										AAdd(aAux,{"U37_QUANT"		,Val(oObjCem:result[nC]:itens[nIt]:quantidade)})
										AAdd(aServicos,aAux)
									Endif
								Endif
							Next nIt
	
							For nI := 1 To Len(oObjCem:result[nC]:autorizados)
	
								aAux := {}
	
								AAdd(aAux,{"U02_NOME"	,oObjCem:result[nC]:autorizados[nI]:nome})
								AAdd(aAux,{"U02_GRAUPA"	,oObjCem:result[nC]:autorizados[nI]:grauparente})
								AAdd(aAux,{"U02_CPF"	,oObjCem:result[nC]:autorizados[nI]:cpf})
								AAdd(aAux,{"U02_CI"		,oObjCem:result[nC]:autorizados[nI]:ci})
								AAdd(aAux,{"U02_ORGAOE"	,oObjCem:result[nC]:autorizados[nI]:orgaoexp})
								AAdd(aAux,{"U02_DTNASC"	,SToD(oObjCem:result[nC]:autorizados[nI]:data)})
								AAdd(aAux,{"U02_SEXO"	,oObjCem:result[nC]:autorizados[nI]:sexo})
								AAdd(aAux,{"U02_ESTCIV"	,oObjCem:result[nC]:autorizados[nI]:estadocivil})
								AAdd(aAux,{"U02_END"	,oObjCem:result[nC]:autorizados[nI]:endereco})
								AAdd(aAux,{"U02_COMPLE"	,oObjCem:result[nC]:autorizados[nI]:complemento})
								AAdd(aAux,{"U02_CEP"	,oObjCem:result[nC]:autorizados[nI]:cep})
								AAdd(aAux,{"U02_EST"	,oObjCem:result[nC]:autorizados[nI]:estado})
								AAdd(aAux,{"U02_CODMUN"	,oObjCem:result[nC]:autorizados[nI]:municipio})
								AAdd(aAux,{"U02_DDD"	,Val(oObjCem:result[nC]:autorizados[nI]:ddd)})
								AAdd(aAux,{"U02_FONE"	,oObjCem:result[nC]:autorizados[nI]:fone})
								AAdd(aAux,{"U02_CELULA"	,oObjCem:result[nC]:autorizados[nI]:celular})
								AAdd(aAux,{"U02_EMAIL"	,oObjCem:result[nC]:autorizados[nI]:email})
	
								AAdd(aAutorizados,aAux)
							Next nI
	
							BeginTran()
	
							//Grava contrato
							If !U_RCPGE004(aCabec,aAutorizados,,3,IIF(Len(aProdutos) > 0,aProdutos,),IIF(Len(aServicos) > 0,aServicos,))
								nRecnoU00	:= 0
								lGravou 	:= .F.
							Else
	
								nRecnoU00 := U00->(Recno())
	
								//Anexa os documentos
								For nY := 1 To Len(oObjCem:result[nC]:anexos)

									//path da imagem no repositorio de imagens
									cPathImg 		:= oObjCem:result[nC]:anexos[nY]:url

									//id da imagem no repositorio
									cIdImagem 		:= oObjCem:result[nC]:anexos[nY]:nome

									//descricao da imagem no repositorio
									cDescricao		:= oObjCem:result[nC]:anexos[nY]:descricao

									AnexaArq(cIdMobile, cPathImg , cIdImagem , cDescricao , "U00",U00->U00_CODIGO)

								Next nY

	
								//Se houve recebimento
								If lReceb
	
									For nF := 1 To Len(oObjCem:result[nC]:fpagtos)
	
										AAdd(aFPagto,{oObjCem:result[nC]:fpagtos[nF]:formapagto,;	//1
										oObjCem:result[nC]:fpagtos[nF]:gateway,;		//2
										oObjCem:result[nC]:fpagtos[nF]:nrocheque,;		//3
										oObjCem:result[nC]:fpagtos[nF]:portador,;		//4
										oObjCem:result[nC]:fpagtos[nF]:agencia,;		//5
										oObjCem:result[nC]:fpagtos[nF]:conta,;			//6
										oObjCem:result[nC]:fpagtos[nF]:valor,;			//7
										oObjCem:result[nC]:fpagtos[nF]:qtparcelas,;		//8
										oObjCem:result[nC]:fpagtos[nF]:vencch,;			//9
										oObjCem:result[nC]:fpagtos[nF]:bandeira})		//10
	
									Next nF
	
									If lContinua
	
										//Ativa o contrato
										U_RCPGE045( U00->U00_CODIGO, .T.)
	
										//Posiciona no titulo a receber de entrada
										If Select("QRYSE1") > 0
											QRYSE1->(DbCloseArea())
										Endif
	
										cQry := "SELECT TOP 1 SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_VENCTO, SE1.E1_VALOR, SE1.E1_MULTA, SE1.E1_JUROS, SE1.E1_DESCONT"
										cQry += " FROM "+RetSqlName("SE1")+" SE1"
										cQry += " WHERE SE1.D_E_L_E_T_ 	<> '*'"
										cQry += " AND SE1.E1_FILIAL 	= '"+xFilial("SE1")+"'"
										cQry += " AND SE1.E1_PREFIXO 	= '"+cPrefCem+"'"
										cQry += " AND SE1.E1_NUM 		= '"+U00->U00_CODIGO+"'"
										cQry += " AND SE1.E1_PARCELA 	= '"+StrZero(1,TamSX3("E1_PARCELA")[1])+"'"
										cQry += " AND SE1.E1_TIPO	 	= '"+cTipoCem+"'"
	
										cQry := ChangeQuery(cQry)
										TcQuery cQry NEW Alias "QRYSE1"
	
										If QRYSE1->(!EOF())
	
											AAdd(aTitulo,QRYSE1->E1_NUM)		//Numero
											AAdd(aTitulo,QRYSE1->E1_PARCELA) 	//Parcela
											AAdd(aTitulo,QRYSE1->E1_VENCTO) 	//Vencimento
											AAdd(aTitulo,QRYSE1->E1_VALOR) 		//Valor
											AAdd(aTitulo,QRYSE1->E1_MULTA) 		//Multa
											AAdd(aTitulo,QRYSE1->E1_JUROS) 		//Juros
											AAdd(aTitulo,QRYSE1->E1_DESCONT)	//Desconto
											AAdd(aTitulo,QRYSE1->E1_VALOR) 		//Valor recebido
											AAdd(aTitulo,cFPagto) 				//Forma de pagamento
											AAdd(aTitulo,0) 					//Valor troco
	
											//Entrada no caixa
											lRet := U_RecebParc(aTitulo,cCliente,cLoja,SToD(oObjCem:result[nC]:data),aFPagto,cPrefCem,cTipoCem,oObjCem:result[nC]:vendedor,U00->U00_CODIGO,@cLogError)
	
											if lRet
	
												///////////////////////////////////////////////////////////////////////////////////////
												/////// IDENTIFICO O LOTE DA BAIXA PARA GERAR MOVIMENTOS NAS TABELAS MDM E MDN ///////
												//////////////////////////////////////////////////////////////////////////////////////
												
												//Gera numero do lote somando + 1 no ultimo lote encontrado
												cLoteBx	:= GetSx8Num("MDN","MDN_LOTE",,2)
												
												MDN->(DbSetOrder(2)) // MDN_FILIAL + MDN_LOTE
												While MDN->(DbSeek(xFilial("MDN") + cLoteBx))
													MDN->(ConfirmSX8())
													cLoteBx := GetSx8Num("MDN","MDN_LOTE",,2)
												EndDo
												
												// se ja estiver em uso eu pego um novo numero para o banco de conhecimento
												While !MayIUseCode("MDN"+xFilial("MDN")+cLoteBx )
													cLoteBx := GetSx8Num("MDN","MDN_LOTE",,2)
												EndDo
		
												//retorna a sequencia da movimentacao gerada na SE5 de acordo com a forma de pagamento
												cSequencia := RetSequenciaSE5(cPrefCem,U00->U00_CODIGO,QRYSE1->E1_PARCELA,cTipoCem)
	
												//Gravo Log dos Titulos Baixados
												LogTitulosBaixados(xFilial("SE1"),;						//Filial do Titulo
												cPrefCem,;							//Prefixo
												U00->U00_CODIGO,;					//Numero do Titulo (Num do Contrato)
												QRYSE1->E1_PARCELA,;				//Parcela Baixada
												cTipoCem,;							//Tipo da Parcela
												SToD(oObjCem:result[nC]:data),;		//Data de Emissao
												cSequencia,;						//Sequecia do Movimento na SE5
												cLoteBx)							//Lote da Baixa
	
												//caso o pagamento seja em cartao, incluo o titulo contra adm financeira ou Emitente do Cheque
												For nZ := 1 To Len(aFPagto)
	
													if aFPagto[nZ,1] $ "CH|CC|CD"
	
														//Gravo Titulo contra a Adm Financeira
														lRet := AdmChqIncluiTitulo(aFPagto[nZ],cVendedor,U00->U00_CODIGO,SToD(oObjCem:result[nC]:data),cLoteBx,1)
	
														if lRet

															FwLogMsg("ERROR",, "REST", FunName(), "", "01", ">> Nao foi possivel incluir titulo contra a Administradora Financeira!", 0, (nStart - Seconds()), {})
	
															Exit
	
														endif
	
													endif
	
												Next nZ
	
											else
												
												FwLogMsg("ERROR",, "REST", FunName(), "", "01", " >> Nao foi possivel receber parcela " + QRYSE1->E1_PARCELA, 0, (nStart - Seconds()), {})
											
											endif
	
										endif
	
									Endif
	
								Else
	
									If !IsBlind()
	
										MsgInfo("A soma dos valores da forma de pagamento de entrada difere do valor de entrada, ativação do contrato cancelada.","Atenção")
	
									Else
	
										FwLogMsg("ERROR",, "REST", FunName(), "", "01", "A soma dos valores da forma de pagamento de entrada difere do valor de entrada, ativação do contrato cancelada.", 0, (nStart - Seconds()), {})
										
	
									Endif
	
								Endif
	
							Endif
	
						Endif
	
						EndTran()
	
						AAdd(aRetorno,{cIdMobile,U00->(Recno()),lGravou,cLogError})
					Endif
				Else
					nRecnoU00 := U00->(Recno())
					AAdd(aRetorno,{cIdMobile,U00->(Recno()),.T.,cLogError})
				Endif
	
				//Em caso de alteração da data do sistema, restaura a data atual
				If lAltData
					dDataBase := dBkpData
				Endif
	
				RestArea(aArea)
				RestArea(aAreaSA1)
				RestArea(aAreaCC2)
	
			Next nC
	
			FreeObj(oObjCem)
	
			For nR := 1 To Len(aRetorno)
	
				//Envia confirmação ao servidor Web
				cJSON := MontaJSON(aRetorno[nR][1],aRetorno[nR][2],aRetorno[nR][3])
				//cJSON := FWJsonSerialize(cJSON,.F.,.F.)
	
				If !Empty(cJSON)
	
					cPostRet := HTTPSPost(cURLCem,"","","","",cJSON,nTimeOut,aHeadOut,@cHeadRet)
	
					//Inclui log da integração
					RecLock("U56",.T.)
					U56->U56_FILIAL := xFilial("U56")
					U56->U56_CODIGO	:= GetSX8Num("U56","U56_CODIGO")
					U56->U56_TABELA	:= "U00"
					U56->U56_RECNO	:= nRecnoU00
					U56->U56_JSON	:= cJSON
					U56->U56_RETORN	:= cPostRet
					U56->U56_DATA	:= dDataBase
					U56->U56_HORA	:= Time()
					U56->U56_USER	:= cUserName
					U56->(MsUnlock())
	
					ConfirmSX8()
	
					//Flag sincronização do registro
					If !Empty(cPostRet) .And. FWJsonDeserialize(cPostRet,@oObjRet)
	
						If aRetorno[nR][3] .And. Lower(oObjRet:code) == "200" //Gravou contrato E houve resposta do retorno
	
							DbSelectArea("U00")
							U00->(DbGoTo(aRetorno[nR][2]))
	
							RecLock("U00",.F.)
							U00->U00_XINTCA := "S"
							U00->(MsUnlock())
						Endif
	
						FreeObj(oObjRet)
					Endif
				Endif
			Next nR
	
		else
	
			//pego o motivo nao obter retorno
			if !IsBlind()
	
				MsgAlert("Não foi possivel obter o retorno dos contratos, motivo: " + Chr(13) + Chr(10) + oRestContCem:GetLastError(),"Atenção!")
	
			else
	
				FwLogMsg("ERROR",, "REST", FunName(), "", "01", "Não foi possivel obter o retorno dos contratos, motivo: " + Chr(13) + Chr(10) + oRestContCem:GetLastError(), 0, (nStart - Seconds()), {})
				
	
			endif
	
		Endif
	
	endif
	
	//Sincronizando contratos funerária
	/*
	Campos obrigatórios
	UF2_PLANO	- Plano
	UF2_PORTAB	- Tipo de contrato
	UF2_VEND	- Vendedor
	UF2_CLIENT	- Cliente
	UF2_LOJA	- Loja
	UF2_INDICE	- Indice
	*/

	aRetorno := {}
	
	//valido se a integracao com o app esta ativa
	if lFunIntegra
		
		oRestContFun := FWRest():New(cHost)

		// defino o timeout da conexao
		oRestContFun:nTimeOut := 30

		// informo o path do metodo
		oRestContFun:SetPath("/contratofun/"+cQtdCttRet)
				
		lRet := oRestContFun:Get(aHeadOut)
		
		If lRet 
	
			FWJsonDeserialize(oRestContFun:GetResult(),@oObjFun)
	
			For nC := 1 To Len(oObjFun:result)

				if !IsBlind()
			
					oSay:cCaption := ("Sincronizando Contrato Id: " + Alltrim(oObjFun:result[nC]:_id) + " / " + cValToChar(nC) + " de: " + cValToChar( Len(oObjFun:result) ) + " ...")
					ProcessMessages()
			
				else
			
					FwLogMsg("INFO",, "REST", FunName(), "", "01", "Sincronizando Contratos Pos-Vida: " + cValToChar(nR) + " de: " + cValToChar( Len(oObjFun:result) ) + " ...", 0, (nStart - Seconds()), {})
								
			
				endif

				cLogError		:= ""
				aCabec 			:= {}
				aBeneficiarios	:= {}
				aFPagto			:= {}
				aProdutos		:= {}
				aTitulo			:= {}
				aMensagem		:= {}
				aAux			:= {}
				lContinua		:= .T.
				lAltData		:= .F.
				lContinua		:= .T.
				lGravou			:= .T.
				lAux			:= .T.

				//Verifica a empresa e filial do contrato
				If oObjFun:result[nC]:cnpj <> SM0->M0_CGC
		
					DbSelectArea("UJ3")
					UJ3->(DbSetOrder(2)) //UJ3_FILIAL+UJ3_CGC
		
					If UJ3->(DbSeek(xFilial("UJ3")+oObjFun:result[nC]:cnpj))
		
						cNewEmp := UJ3->UJ3_CODIGO
						cNewFil	:= UJ3->UJ3_CODFIL
		
						RpcSetType(3)
						Reset Environment
						RpcSetEnv(cNewEmp,cNewFil)
					Else
						lAux := .F.
					Endif
				Else
		
					DbSelectArea("UJ3")
					
					UJ3->(DbSetOrder(2)) //UJ3_FILIAL+UJ3_CGC
					
					If !UJ3->(DbSeek(xFilial("UJ3")+oObjFun:result[nC]:cnpj))
					
						cLogError := "CGC da empresa informada nao foi localizada no cadastro de EMPRESAS INTEGRACAO"
					
						lAux := .F.
					
					Endif
		
				Endif

				//valido se logou na empresa
				if lAux

					/////////////////////////////////////////////////////////////////
					////// CHAVE DE INTEGRACAO COM O VIRTUS - CPF DO VENDEDOR //////
					////////////////////////////////////////////////////////////////
					SA3->(DbSetOrder(3)) //A3_FILIAL + A3_CGC
					
					cIdMobile		:= oObjFun:result[nC]:_id
						
					cCPFVendedor	:= Alltrim(oObjFun:result[nC]:vendedor)
		
					if SA3->(DbSeek(xFilial("SA3") + cCPFVendedor))
						
						cVendedor 	:= SA3->A3_COD
						cCxVend		:= U_UxNumCx(cVendedor)

						//Valido se o vendedor possui caixa
						If !Empty(cCxVend)
							
							FwLogMsg("INFO",, "REST", FunName(), "", "01", "Json Recebido: " + oRestContFun:GetResult(), 0, (nStart - Seconds()), {})

							aArea			:= GetArea()
							aAreaSA1		:= SA1->(GetArea())
							aAreaCC2		:= CC2->(GetArea())
			
							If lAux //Posicinou numa empresa de integração
			
								//Verifica se a data da venda é inferior a data atual/sincronização, se sim, alteara a data do sistema
								If SToD(oObjFun:result[nC]:data) < dDataBase
									dBkpData	:= dDataBase
									dDataBase 	:= SToD(oObjFun:result[nC]:data)
									lAltData	:= .T.
								Endif
								
								lReceb			:= IIF(oObjFun:result[nC]:recebeu == "verdadeiro",.T.,.F.)
								cCpfCnjp		:= oObjFun:result[nC]:cpfcnpj
								oDadosAdiant	:= oObjFun:result[nC]:adiantamento  // dados do adiantamento
								oDadosAdesao	:= oObjFun:result[nC]:adesao 		// dados da adesao
								oDadosRecor		:= oObjFun:result[nC]:recorrencia 	// dados da recorrencia
			
								//Chamo funcao para Validar dados recorrencia foram recebidos
								lRet := checkJsonRet( oObjFun:result[nC]:formapagtoparcelas,oDadosRecor,cCpfCnjp,@cLogError)

								//Se retornar .F. nao permite gravar contrato
								if !lRet

									AAdd(aRetorno,{cIdMobile,0,.F.,cLogError})
									Loop
								Endif

								DbSelectArea("UF2")
								UF2->(DbOrderNickName("IDMOBILE")) //UF2_FILIAL+UF2_IDMOBI
			
								If !UF2->(DbSeek(xFilial("UF2")+cIdMobile))
			
									DbSelectArea("SA1")
									SA1->(DbSetOrder(3)) //A1_FILIAL+A1_CGC
			
									If SA1->(DbSeek(xFilial("SA1")+cCpfCnjp)) //Novo cliente
										nOperCli := 4
									else
										nOperCli := 3
									endif

									//Cadastra Cliente
									oRestCliente := FWRest():New(cHost)
									oRestCliente:setPath("/cliente/"+cCpfCnjp+"")
			
									If oRestCliente:Get(aHeadOut)
			
										oObjCli := Nil
			
										FWJsonDeserialize(oRestCliente:GetResult(),@oObjCli)
			
										cNome		:= oObjCli:result:nome
										cTpPessoa	:= oObjCli:result:tipopessoa
										cNReduz		:= oObjCli:result:nomereduzido
										cEnd		:= oObjCli:result:endereco
										cCompl		:= oObjCli:result:complemento
										cPtoRef		:= oObjCli:result:pontoref
										cBairro		:= oObjCli:result:bairro
										cEst		:= oObjCli:result:estado
										cCodMun		:= PadL(oObjCli:result:municipio,TamSx3("A1_COD_MUN")[1],"0")
										cCep		:= oObjCli:result:cep
										cDdd		:= oObjCli:result:ddd
										cTel		:= oObjCli:result:tel
										cCgc		:= oObjCli:result:cpfcnpj
										cRg			:= oObjCli:result:rg
										cInscEst	:= oObjCli:result:inscestadual
										cInscMun	:= oObjCli:result:inscmunicipal
										cEmail		:= oObjCli:result:email
										cIdMobCli	:= oObjCli:result:_id
										cCelular	:= oObjCli:result:celular
										cDDDCel		:= oObjCli:result:dddcel
										dDataNasc	:= STOD(oObjCli:result:datanasc)
										cEstCivil	:= oObjCli:result:estadocivil
										cProfissao	:= oObjCli:result:profissao
											
										If CadCli(cNome,cTpPessoa,cNReduz,cEnd,cCompl,cPtoRef,cBairro,cEst,cCodMun,cCep,cDdd,cTel,cCgc,cRg,cInscEst,cInscMun,cEmail,cIdMobCli,cCelular,cDDDCel,dDataNasc,cEstCivil,cProfissao,@cLogError,nOperCli)
			
											cCliente 	:= SA1->A1_COD
											cLoja		:= SA1->A1_LOJA
											nRecnoSA1	:= SA1->(Recno())
										Else
											lContinua := .F.
										Endif
			
										//Inclui log da integração
										RecLock("U56",.T.)
										U56->U56_FILIAL := xFilial("U56")
										U56->U56_CODIGO	:= GetSX8Num("U56","U56_CODIGO")
										U56->U56_TABELA	:= "SA1"
										U56->U56_RECNO	:= nRecnoSA1
										U56->U56_JSON	:= oRestCliente:GetResult()
										U56->U56_RETORN	:= ""
										U56->U56_DATA	:= dDataBase
										U56->U56_HORA	:= Time()
										U56->U56_USER	:= cUserName
										U56->(MsUnlock())
			
										ConfirmSX8()
			
										FreeObj(oObjCli)
			
										//nao obteve retorno da API de clientes
									else
			
										lContinua := .F.

										//pego o motivo nao obter retorno
										if !IsBlind()
											MsgAlert("Não foi possivel obter o retorno dos Clientes, motivo: " + Chr(13) + Chr(10) + oRestCliente:GetLastError(),"Atenção!")
										else
											
											cLogError := "Não foi possivel obter o retorno dos Clientes, motivo: " + Chr(13) + Chr(10) + oRestCliente:GetLastError()
											FwLogMsg("ERROR",, "REST", FunName(), "", "01", cLogError, 0, (nStart - Seconds()), {})

										endif
									Endif
				
									If lContinua
			
										AAdd(aCabec,{"UF2_PLANO"	,oObjFun:result[nC]:plano})
										AAdd(aCabec,{"UF2_VEND"		,cVendedor})
										AAdd(aCabec,{"UF2_DATA"		,SToD(oObjFun:result[nC]:data)})
										AAdd(aCabec,{"UF2_PORTAB"	,oObjFun:result[nC]:tipo})
										AAdd(aCabec,{"UF2_MIDIA"	,oObjFun:result[nC]:midia})
										AAdd(aCabec,{"UF2_PRIMVE"	,SToD(oObjFun:result[nC]:vencimento)})
										AAdd(aCabec,{"UF2_CLIENT"	,cCliente})
										AAdd(aCabec,{"UF2_LOJA"		,cLoja})
										AAdd(aCabec,{"UF2_INDICE"	,cTpIndice})
										AAdd(aCabec,{"UF2_TXMNT"	,nTxManuFun})
										AAdd(aCabec,{"UF2_IDMOBI"	,cIdMobile})
										AAdd(aCabec,{"UF2_FORPG"	,oObjFun:result[nC]:formapagtoparcelas})
										
										For nI := 1 To Len(oObjFun:result[nC]:beneficiarios)
			
											aAux := {}
			
											AAdd(aAux,{"UF4_ITEM"	,StrZero(nI + 1,TamSX3("UF4_ITEM")[1])})
											AAdd(aAux,{"UF4_GRAU"	,oObjFun:result[nC]:beneficiarios[nI]:grauparente})
											AAdd(aAux,{"UF4_TIPO"	,cValToChar(oObjFun:result[nC]:beneficiarios[nI]:tipo)})
											AAdd(aAux,{"UF4_DTINC"	,dDataBase})
											AAdd(aAux,{"UF4_CAREN"	,CarBenFun(oObjFun:result[nC]:tipo,SToD(oObjFun:result[nC]:data))})
											AAdd(aAux,{"UF4_NOME"	,Alltrim(oObjFun:result[nC]:beneficiarios[nI]:nome) }) 
											AAdd(aAux,{"UF4_DTNASC"	,SToD(oObjFun:result[nC]:beneficiarios[nI]:datanasc)})
											AAdd(aAux,{"UF4_SEXO"	,oObjFun:result[nC]:beneficiarios[nI]:sexo})
											AAdd(aAux,{"UF4_ESTCIV"	,oObjFun:result[nC]:beneficiarios[nI]:estadocivil})
											AAdd(aAux,{"UF4_CPF"	,oObjFun:result[nC]:beneficiarios[nI]:cpf})
											AAdd(aAux,{"UF4_TPPLN"	,oObjFun:result[nC]:beneficiarios[nI]:seguro})
											
											AAdd(aBeneficiarios,aAux)
										Next nI
			
										For nIt := 1 To Len(oObjFun:result[nC]:itens)
			
											If SB1->(DbSeek(xFilial("SB1")+oObjFun:result[nC]:itens[nIt]:item))
			
												aAux := {}
			
												AAdd(aAux,{"UF3_ITEM" 		,StrZero(nIt,TamSX3("UF3_ITEM")[1])})
												AAdd(aAux,{"UF3_PROD"		,oObjFun:result[nC]:itens[nIt]:item})
												AAdd(aAux,{"UF3_QUANT"		,Val(oObjFun:result[nC]:itens[nIt]:quantidade)})
												AAdd(aProdutos,aAux)
											
											Endif
										
										Next nIt
			
										BeginTran()
										
										//verifico se possui observacao para o contrato, caso possua sera incluida como mensagem
										if !Empty(oObjFun:result[nC]:observacao)
											
											cMensagem	:= Alltrim(oObjFun:result[nC]:observacao)
											aAux 		:= {}
											aMensagem	:= {}
											
											AAdd(aAux,{"UF9_ITEM" 	, StrZero(1,TamSX3("UF9_ITEM")[1] ) 			} )
											AAdd(aAux,{"UF9_HISTOR" , SubStr(cMensagem,1,TamSX3("UF9_HISTOR")[1]) 	} )
											AAdd(aAux,{"UF9_DESCRI" , cMensagem										} )
											AAdd(aAux,{"UF9_MOSTRA" , "S"											} )
											AAdd(aAux,{"UF9_DTVIGE" , CTOD("01/01/2049")							} )
											
											AAdd(aMensagem,aAux)
											
										endif
										
										//Grava contrato
										If !U_RFUNE002(aCabec,aBeneficiarios,aMensagem,3,IIF(Len(aProdutos) > 0,aProdutos,),@cLogError)
											nRecnoUF2	:= 0
											lGravou 	:= .F.
											
											FwLogMsg("ERROR",, "REST", FunName(), "", "01",cLogError, 0, (nStart - Seconds()), {})

										Else
			
											FwLogMsg("INFO",, "REST", FunName(), "", "01", ">> Contrato incluido com sucesso", 0, (nStart - Seconds()), {})

											nRecnoUF2 := UF2->(Recno())
											
											//Nome arquivo = Id Mobile + Contrato + sequencia
											For nY := 1 To Len(oObjFun:result[nC]:anexos)

												//path da imagem no repositorio de imagens
												cPathImg 		:= oObjFun:result[nC]:anexos[nY]:url

												//id da imagem no repositorio
												cIdImagem 		:= oObjFun:result[nC]:anexos[nY]:nome

												//descricao da imagem no repositorio
												cDescricao		:= oObjFun:result[nC]:anexos[nY]:descricao

												AnexaArq(cIdMobile, cPathImg , cIdImagem , cDescricao , "UF2",UF2->UF2_CODIGO )

											Next nY


			
											////////////////////////////////////////////////////////////
											///////////////////		RECORRENCIA		////////////////////
											////////////////////////////////////////////////////////////
			
											// se o cliente foi enviado para Vindi
											if !Empty(oDadosRecor:idClienteVindi)
			
												// faço a inclusão do cliente e perfil de pagamento
												lRet := oVindi:IncManVind(cValToChar(oDadosRecor:idClienteVindi),UF2->UF2_CODIGO,UF2->UF2_CLIENT,UF2->UF2_LOJA,cValToChar(oDadosRecor:idPerfilPgto),oObjFun:result[nC]:formapagtoparcelas,oDadosRecor:nomeClienteCartao,oDadosRecor:ultimosDigitosCartao,oDadosRecor:validade,oDadosRecor:bandeira,oDadosRecor:token)
			
											endif
											
											//Valido se ativa contrato
											if lRet 

												////////////////////////////////////////////////////////////
												////////////		ATIVAÇÃO DO CONTRATO		////////////
												////////////////////////////////////////////////////////////
				
												// se o a quantidade de parcelas adiantadas for maior que a quantidade de parcelas Default da Funerária (MV_XQTDPAR)
												if Val(oDadosAdiant:parcelaAdiantamento) > nQtdParcFun
													// enviar para ativação a quantidade de parcelas do mobile
													nQtdParc := Val(oDadosAdiant:parcelaAdiantamento)
												else
													// envia valor zerado para que a rotina de ativação considere as parcelas padrões
													nQtdParc := 0
												endif
				
												//Ativa o contrato
												if !U_RFUNA004(.T.,nQtdParc,Val(oDadosAdiant:parcelaAdiantamento))
													
													cLogError	:= "Erro na Ativação do Contrato"
													nRecnoUF2	:= 0
													lGravou 	:= .F.
												endif			
												////////////////////////////////////////////////////////////
												//////////////////  		ADESAO		////////////////////
												////////////////////////////////////////////////////////////
				
												// se o contrato tem taxa de adesao
												if UF2->UF2_ADESAO > 0
				
													aFPagto := {}
				
													For nF := 1 To Len(oDadosAdesao:fpagtos)

														AAdd(aFPagto,{oDadosAdesao:fpagtos[nF]:formapagto,;		//1
														oDadosAdesao:fpagtos[nF]:gateway,;			//2
														oDadosAdesao:fpagtos[nF]:nrocheque,;		//3
														oDadosAdesao:fpagtos[nF]:portador,;			//4
														oDadosAdesao:fpagtos[nF]:agencia,;			//5
														oDadosAdesao:fpagtos[nF]:conta,;			//6
														oDadosAdesao:fpagtos[nF]:valor,;			//7
														oDadosAdesao:fpagtos[nF]:qtparcelas,;		//8
														oDadosAdesao:fpagtos[nF]:vencch,;			//9
														oDadosAdesao:fpagtos[nF]:bandeira,;			//10
														oDadosAdesao:fpagtos[nF]:nsu,;				//11
														oDadosAdesao:fpagtos[nF]:aut})				//12

													Next nF
				
													// faz o cálculo do desconto concedido na adesão
													nDescontoAdesao := UF2->UF2_ADESAO - Val(oDadosAdesao:valorPago)
				
													// se o valor pago for maior que o valor da adesão, desconsidero o valor excedido
													if nDescontoAdesao < 0
														nDescontoAdesao := 0
													endif
				
													lGravou := RecAdesao(cPrefFun,UF2->UF2_CODIGO,cTipoFun,SToD(oObjFun:result[nC]:data),cVendedor,nDescontoAdesao,aFPagto,@cLogError)
				
													if lGravou

														If (UF2->( FieldPos("UF2_XPERAD") ) > 0);
															.And. (UF2->( FieldPos("UF2_XVLDES") ) > 0)

															RecLock("UF2", .F.)
																UF2->UF2_XPERAD := IIF(nDescontoAdesao > 0, cValToChar(((nDescontoAdesao * 100) / UF2->UF2_ADESAO)), "")
																UF2->UF2_XVLDES := nDescontoAdesao
															UF2->( MsUnLock() )
														EndIf
														
														FwLogMsg("ERROR",, "REST", FunName(), "", "01", "Adesao recebida com sucesso", 0, (nStart - Seconds()), {})

													else
														
														FwLogMsg("ERROR",, "REST", FunName(), "", "01", ">> Erro no recebimento da Adesao", 0, (nStart - Seconds()), {})

													endif
				
												else
													nDescontoAdesao := 0
												endif
				
												////////////////////////////////////////////////////////////
												////////////////		ADIANTAMENTO		////////////////
												////////////////////////////////////////////////////////////
				
												// se foi realizado um adiantamento de parcelas
												if Val(oDadosAdiant:parcelaAdiantamento) > 0
				
													aFPagto := {}
				
													For nF := 1 To Len(oDadosAdiant:fpagtos)
				
														AAdd(aFPagto,{oDadosAdiant:fpagtos[nF]:formapagto,;		//1
														oDadosAdiant:fpagtos[nF]:gateway,;			//2
														oDadosAdiant:fpagtos[nF]:nrocheque,;		//3
														oDadosAdiant:fpagtos[nF]:portador,;			//4
														oDadosAdiant:fpagtos[nF]:agencia,;			//5
														oDadosAdiant:fpagtos[nF]:conta,;			//6
														oDadosAdiant:fpagtos[nF]:valor,;			//7
														oDadosAdiant:fpagtos[nF]:qtparcelas,;		//8
														oDadosAdiant:fpagtos[nF]:vencch,;			//9
														oDadosAdiant:fpagtos[nF]:bandeira,;		//10
														oDadosAdiant:fpagtos[nF]:nsu,;				//11
														oDadosAdiant:fpagtos[nF]:aut})	
					
													Next nF
				
													lGravou := RecAdiant(cPrefFun,UF2->UF2_CODIGO,cTipoFun,SToD(oObjFun:result[nC]:data),cVendedor,Val(oDadosAdiant:parcelaAdiantamento),aFPagto,@cLogError)
				
													if lGravou
														
														FwLogMsg("INFO",, "REST", FunName(), "", "01", ">> Adiantamento recebido com sucesso", 0, (nStart - Seconds()), {})

													else
														
														FwLogMsg("ERROR",, "REST", FunName(), "", "01", ">> Erro no recebimento do Adiantamento", 0, (nStart - Seconds()), {})

													endif
				
												endif
											Else
												
												cLogError := "Erro na gravacao do cliente e perfil de pagamento no Protheus"
												
												FwLogMsg("ERROR",, "REST", FunName(), "", "01", cLogError, 0, (nStart - Seconds()), {})
												lGravou := .F.
											Endif	
										Endif
															
										if lGravou
											// confirma a transação
											EndTran()
										else
											// aborto a transação
											DisarmTransaction()
										endif
			
										//caso nao tenha gravado, nao retorno o numero do contrato para virtus
										if lGravou
											AAdd(aRetorno,{cIdMobile,UF2->(Recno()),lGravou,cLogError})
										else
											AAdd(aRetorno,{cIdMobile,0,lGravou,cLogError})
										endif
									else
										AAdd(aRetorno,{cIdMobile,0,.F.,cLogError})
									Endif
								Else
									cLogError := "Id Mobile informado ja existe vinculado ao contrato + "+ UF2->UF2_CODIGO + " no Protheus"
									
									FwLogMsg("ERROR",, "REST", FunName(), "", "01", cLogError, 0, (nStart - Seconds()), {})
									nRecnoUF2 := UF2->(Recno())
									AAdd(aRetorno,{cIdMobile,UF2->(Recno()),.T.,cLogError})
								Endif
			
								//Em caso de alteração da data do sistema, restaura a data atual
								If lAltData
									dDataBase := dBkpData
								Endif
							Endif

							RestArea(aArea)
							RestArea(aAreaSA1)
							RestArea(aAreaCC2)

						else

							cLogError := "Vendedor: " + Alltrim(cCPFVendedor) + " nao possui caixa cadastrado, favor verifique o cadastro do Caixa!"	
							
							FwLogMsg("ERROR",, "REST", FunName(), "", "01", cLogError, 0, (nStart - Seconds()), {})
							AAdd(aRetorno,{cIdMobile,0,.F.,cLogError})

						endIf		
											
					else

						cLogError := "Vendedor: " + Alltrim(cCPFVendedor) + " nao encontrado, favor verifique o cadastro no App!"	
						
						FwLogMsg("ERROR",, "REST", FunName(), "", "01", cLogError, 0, (nStart - Seconds()), {})
						AAdd(aRetorno,{cIdMobile,0,.F.,cLogError})
						
					endif
				
				endif

			Next nC
	
			FreeObj(oObjFun)
	
			For nR := 1 To Len(aRetorno)
	
				//Envia confirmação ao servidor Web
				cJSON := MontaJSON(aRetorno[nR][1],aRetorno[nR][2],aRetorno[nR][3],aRetorno[nR][4])
				//cJSON := FWJsonSerialize(cJSON,.F.,.F.)
	
				If !Empty(cJSON)
	
					cPostRet := HTTPSPost(cURLFun,"","","","",cJSON,nTimeOut,aHeadOut,@cHeadRet)
	
					//Inclui log da integração
					RecLock("U56",.T.)
					U56->U56_FILIAL := xFilial("U56")
					U56->U56_CODIGO	:= GetSX8Num("U56","U56_CODIGO")
					U56->U56_TABELA	:= "UF2"
					U56->U56_RECNO	:= nRecnoUF2
					U56->U56_JSON	:= cJSON
					U56->U56_RETORN	:= cPostRet
					U56->U56_DATA	:= dDataBase
					U56->U56_HORA	:= Time()
					U56->U56_USER	:= cUserName
					U56->(MsUnlock())
	
					ConfirmSX8()
	
					//Flag sincronização do registro
					If !Empty(cPostRet) .And. FWJsonDeserialize(cPostRet,@oObjRet)
	
						FreeObj(oObjRet)
					Endif
				Endif
			Next nR
		else
	
			//pego o motivo nao obter retorno
			if !IsBlind()
	
				MsgAlert("Não foi possivel obter o retorno dos contratos, motivo: " + Chr(13) + Chr(10) + oRestContFun:GetLastError(),"Atenção!")
	
			else

				cLogError := "Não foi possivel obter o retorno dos contratos, motivo: " + Chr(13) + Chr(10) + oRestContFun:GetLastError()
				FwLogMsg("ERROR",, "REST", FunName(), "", "01", cLogError, 0, (nStart - Seconds()), {})
				
			endif
	
		Endif
	
	endif
	
	// destruo o objeto da vindi
	FreeObj(oVindi)

Return

/*****************************************************/
Static Function MontaJSON(cIdMobile,cContrato,lGravou,cMsgErro)
	/*****************************************************/

	Local cRet 			:= ""

	Local aCab 			:= {}
	Local aLin 			:= {}
	Local cQry			:= ""

	cRet := '{'
	cRet +=	'"_id":"' 	   + cIdMobile 							+ '",'
	cRet +=	'"contrato":"' + cValtoChar(cContrato)				+ '",'
	cRet +=	'"retorno":"'  + iif(lGravou,"verdadeiro","falso") 	+ '",'
	cRet +=	'"log":"' 	   + cMsgErro							+ '"'
	cRet +=	'}'

Return cRet

/*********************************/
Static function ConfJSON(aGeraXML)
	/*********************************/

	Local nI,nJ

	Local cJSON  := ""

	Local cTable := aGeraXML[1]
	Local aCab   := aGeraXML[2]
	Local aLin   := aGeraXML[3]

	If !Empty(cTable)
		cJSON += '"'+cTable+'": ['
	Endif

	For nI := 1 To Len(aLin)

		//cJSON += '{' + CRLF

		For nJ := 1 To Len(aCab)

			If ValType(aLin[nI][nJ]) = "C"
				cConteudo := AllTrim(aLin[nI][nJ])
			ElseIf ValType(aLin[nI][nJ]) = "N"
				cConteudo := cValToChar(aLin[nI][nJ])
			ElseIf ValType(aLin[nI][nJ]) = "D"
				cConteudo := IIF(!Empty(aLin[nI][nJ]),DToC(aLin[nI][nJ]),"")
			ElseIf ValType(aLin[nI][nJ]) = "L"
				cConteudo := IIf(aLin[nI][nJ],"verdadeiro","falso")
			Else
				cConteudo := AllTrim(aLin[nI][nJ])
			Endif

			cJSON += '"'+aCab[nJ]+'":' + '"'+cConteudo+'"'

			If nJ < Len(aCab)
				cJSON += ',' + CRLF
			Endif

		Next nJ

		//cJSON += CRLF + '}'

		If nI < Len(aLin)
			cJSON += ','
		Endif
	Next nI

	If !Empty(cTable)
		cJSON += ']'
	Endif

Return cJSON

/*******************************************************************************************************************************************************************************************/
Static Function CadCli(cNome,cTpPessoa,cNReduz,cEnd,cCompl,cPtoRef,cBairro,cEst,cCodMun,cCep,cDdd,cTel,cCgc,cRg,cInscEst,cInscMun,cEmail,cIdMobile,cCelular,cDDDCel,dDataNasc,cEstCivil,cProfissao,cLogError,nOperCli)
/*******************************************************************************************************************************************************************************************/

	Local lRet		:= .T.
	Local aSA1Auto  := {}
	Local aAI0Auto  := {}
	Local nOpcAuto  := MODEL_OPERATION_INSERT

	Private lMsErroAuto := .F.

	//Se for alteracao
	if nOperCli == 4

		AAdd(aSA1Auto,{"A1_COD"		,SA1->A1_COD	,NIL})
		AAdd(aSA1Auto,{"A1_LOJA"    ,SA1->A1_LOJA	,NIL})

	endif

	AAdd(aSA1Auto,{"A1_NOME"		,Alltrim(Upper(cNome))	,NIL})
	AAdd(aSA1Auto,{"A1_PESSOA"    	,cTpPessoa				,NIL})
	AAdd(aSA1Auto,{"A1_NREDUZ"		,Upper(cNReduz)			,NIL})
	AAdd(aSA1Auto,{"A1_END"			,Upper(cEnd)			,NIL})
	AAdd(aSA1Auto,{"A1_COMPLEM"		,Upper(cCompl)			,NIL})
	AAdd(aSA1Auto,{"A1_XREFERE"		,Upper(cPtoRef)			,NIL})
	AAdd(aSA1Auto,{"A1_BAIRRO"		,Upper(cBairro)			,NIL})
	AAdd(aSA1Auto,{"A1_EST"			,Upper(cEst)			,NIL})
	AAdd(aSA1Auto,{"A1_CEP"			,cCep 					,NIL})
	AAdd(aSA1Auto,{"A1_DDD"			,cDdd					,NIL})
	AAdd(aSA1Auto,{"A1_TEL"			,cTel					,NIL})
	AAdd(aSA1Auto,{"A1_CGC"	    	,cCgc					,NIL})
	AAdd(aSA1Auto,{"A1_RG"	    	,cRg					,NIL})
	AAdd(aSA1Auto,{"A1_INSCR"		,cInscEst				,NIL})
	AAdd(aSA1Auto,{"A1_INSCRM"		,cInscMun				,NIL})
	AAdd(aSA1Auto,{"A1_EMAIL"		,Upper(cEmail)			,NIL})
	AAdd(aSA1Auto,{"A1_XINTCA"		,"S"					,NIL})
	AAdd(aSA1Auto,{"A1_XIDMOBI"		,cIdMobile				,NIL})
	AAdd(aSA1Auto,{"A1_COD_MUN"		,cCodMun 				,NIL})
	AAdd(aSA1Auto,{"A1_XCEL"		,cCelular 				,NIL})
	AAdd(aSA1Auto,{"A1_XDDDCEL"		,cDDDCel 				,NIL})
	AAdd(aSA1Auto,{"A1_XDTNASC"		,dDataNasc 				,NIL})
	AAdd(aSA1Auto,{"A1_XESTCIV"		,cEstCivil 				,NIL})
	AAdd(aSA1Auto,{"A1_XPROFIS"		,cProfissao				,NIL})

	MsExecAuto({|x,y| MATA030(x,y)},aSA1Auto,nOperCli) //3=Inclusao 4=Alteracao
	//MV_MVCSA1 = .T. para habilitar o cadastro MVC
	//MSExecAuto({|a,b,c| CRMA980(a,b,c)}, aSA1Auto, nOpcAuto, aAI0Auto)

	If lMsErroAuto

		If !IsBlind()
			MostraErro()
			Help(,,'Help',,"Titular nï¿½o inserido: " + cCgc ,1,0)
		Endif

		cLogError := "Erro ExecAuto para inclusao do Titular : " + cCgc 
		DisarmTransaction()
		lRet := .F.
	Else
		SA1->(DbSeek(xFilial("SA1")+cCgc))
	Endif

Return lRet

/***********************************************************************************************/
User Function RecebParc(aTitulo,cCliente,cLoja,dDtReceb,aFPagto,cPref,cTipo,cVendedor,cContrato,cLogError)
	/***********************************************************************************************/

	Local aArea			:= GetArea()
	Local nTamE1Tipo	:= TamSx3("E1_TIPO")[1]					// Tamanho do campo no SX3
	Local lRet			:= .T.		   							// Retorno da funcao
	Local nSE1Recno		:= 0	   								// Utilizado na funcao GeraTit para reposicionar no titulo baixado por essa funcao
	Local nSE5Recno		:= 0									// Utilizado na funcao GeraTit para reposicionar no titulo baixado por essa funcao
	Local nI			:= 0		 							// Contador do For
	Local nX			:= 0		  							// Contador do For
	Local cMvLjReceb	:= SuperGetMv("MV_LJRECEB",.F.,"1")		// Parametro de controle do Recebimento
	Local nTroco 		:= 0									// Valor de troco
	Local nStart		:= Seconds()

	Local cCodUsr		:= ""
	Local cNomeUsr		:= ""

	DbSelectArea("SA1")
	SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
	SA1->(DbSeek(xFilial("SA1")+cCliente+cLoja))

	For nI := 1 to Len(aFPagto)

		/*LJRecBXSE1( cMV_LJRECEB		, cPrefixo 		, cNum			, cParcela		,;
		dVencimento		, nValor		, nVlrMulta		, nVlrJuros		,;
		nVlrDesconto	, nVlrRecebido	, cTipo			, cCartFrt		,;
		cFilialTit		, cFrmPag		, lPrimBaixa	, nPrimMulta	,;
		nPrimJuros		, nPrimDescon	, nTotReceb		, aSE5Dados		,;
		lPgTef			, cNomeUser		, nValAbat		, aSE5Bxas		,;
		aTitBxSE5		, cNumCheque	, aTitDelSE5	, nValTroco		,;
		nMoeda			, nRecnoSE5 	, lWS			, cNumMov		,;
		aNsuVndTef		) */

		cCodUsr 	:= Posicione("SA3",1,xFilial("SA3")+cVendedor,"A3_CODUSR")
		cNomeUsr	:= UsrRetName(cCodUsr)

		DbSelectArea("SE1")
		SE1->(DbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
		SE1->(DbSeek(xFilial("SE1") + cPref + aTitulo[TIT_NUM] + aTitulo[TIT_PARC] + cTipo))

		oVirtusFin := VirtusFin():New()
		lRet := oVirtusFin:ULJRecBX(;
			aTitulo[TIT_MULTA]	, aTitulo[TIT_JUROS]	, ;
			aTitulo[TIT_DESC]	, aFPagto[nX][7]		, Nil					, ;
			xFilial("SE1")		, aFPagto[nX][1]		, Nil			   		, Nil					, ;
			Nil					, Nil					, Nil			 		, Nil					, ;
			.F.					, cNomeUsr				, 0				 		, Nil					, ;
			Nil					, aFPagto[nX][3]		, Nil			 		, aTitulo[TIT_TROCO]	, ;
			1 																							)
		
		If !lRet
			cLogError := "RecebParc - Falha na execucao da funcao: " + "LjRecBXSE1"
			
			FwLogMsg("ERROR",, "REST", FunName(), "", "01", cLogError, 0, (nStart - Seconds()), {})

		EndIf

	Next nI

	SE1->(DbCloseArea())
	SA1->(DbCloseArea())

	FreeObj(oVirtusFin)
	oVirtusFin := Nil

	RestArea(aArea)

Return(lRet)

//----------------------------------------------------------------
/*/{Protheus.doc} LjIncTitRec
Funcao que cria um titulo a receber a partir da forma de pagamento
Exemplo: Se o titulo foi pago com CC, devemos criar um
titulo a receber para a administradora financeira
@param   oPagamento	Estruturas de formas de pagamentos
@param   cPortado	E1_PORTADO
@param   cLoteBx	Numero do lote do titulo
@author  Vendas & CRM
@version P11.5
@since   27/06/2012
@return  lRet	.T. Quando o titulo foi gerado com sucesso
/*/
//----------------------------------------------------------------
User Function ULjIncTitRec(aFPagto,cPortado,cLoteBx,dDtReceb,cVendedor,cContrato,nQtdParcelas,cLogError)

	Local nTamMDNLt	:= TamSX3("MDN_LOTE")[1]   			// Tamanho do campo no SX3
	Local nTamE1Num	:= TamSX3("E1_NUM")[1]	  			// Tamanho do campo no SX3
	Local nTamAECod	:= TamSX3("AE_COD")[1]	  			// Tamanho do campo no SX3
	Local lRet		:= .T.					  			// Retorno da funcao
	Local aSE1		:= {}					  			// Array de gravacao do SE1
	Local aMDM		:= {}						 		// Array de gravacao da MDM
	Local aMDN		:= {}						 		// Array de gravacao da MDN
	Local aParcelas	:= {}								// Array de controle de parcelas
	Local cPrefixo	:= SuperGetMV("MV_LJTITGR",,"REC")	// Prefixo de gravacao do titulo
	Local cNumTitulo:= Space(0)							// Numero do titulo
	Local cNatureza	:= Space(0)							// Natureza do titulo
	Local cFormaPgto:= Space(0)							// Forma de pagamento do titulo
	Local nI		:= 0								// Contador do For
	Local nX		:= 0								// Contador do For
	Local cBcoChq	:= ""								// Banco do cheque
	Local cAgeChq	:= ""								// Agencia do cheque
	Local cContaChq	:= ""								// Conta-corrente do cheque

	Local cAgeDep	:= ""
	Local cConta	:= ""

	Local lMvLjGerTx	:= SuperGetMV( "MV_LJGERTX",, .F. )
	Local cCodFornec	:= ""
	Local nValorTaxa	:= 0
	Local aVetorSE2		:= {}

	Local nStart		:= Seconds()

	Default cPortado	:= CriaVar("E1_PORTADO")
	Default cLoteBx		:= ""
	Default cVendedor	:= ""
	Default cContrato	:= ""

	Private lMsErroAuto	:= .F.

	cFormaPgto := aFPagto[1]

	If AllTrim(cFormaPgto) $ "CC|CD|CO|FI"
		aParcelas := LJCriaParcelas(cFormaPgto, Val(aFPagto[7]) * nQtdParcelas , dDtReceb, Val(aFPagto[8]),cValToChar(aFPagto[2]),UPPER(aFPagto[10]),aFPagto[11],aFPagto[12],@cLogError)
	Else
		aParcelas := LJCriaParcelas(cFormaPgto, Val(aFPagto[7]) * nQtdParcelas , IIF(!Empty(SToD(aFPagto[9])),SToD(aFPagto[9]),dDtReceb))
	EndIf

	//caso nao tenha carregados os dados para inclusao do titulo a receber da forma de pagamento, nao prossigo a operacao
	if Len(aParcelas) > 0

		//Chama funcao do loja(GetNumSE1) Obtemos o numero do titulo disponivel
		//para gerar o titulo contra administradora
		cNumTitulo := U_GetNumMDM(cPrefixo)//GetNumSE1(cPrefixo)

		//Obtemos a natureza atraves do tipo de titulo
		Do Case
		Case AllTrim(cFormaPgto) == "CC"

			cNatureza	:= &(SuperGetMV("MV_NATCART"))

		Case AllTrim(cFormaPgto) == "CH"

			cNatureza	:= &(SuperGetMV("MV_NATCHEQ"))
			cBcoChq		:= aFPagto[4]
			cAgeChq		:= aFPagto[5]
			cContaChq	:= aFPagto[6]

		Case AllTrim(cFormaPgto) == "CD"

			cNatureza	:= SuperGetMV("MV_NATTEF")

			If SubStr(cNatureza,1,1) == "&"

				cNatureza := SubStr(cNatureza,2,Len(cNatureza))
				//Se MV_NATTEF Iniciar com & passo o conteudo apartir do segundo byte para ser expandido via macro,
				//senao passo o label para na expansao pegar o conteudo
				cNatureza := &(cNatureza)

			ElseIf SubStr(cNatureza, 1, 1) == "'" // Tratamento no caso de o parametro MV_NATTEF ter sido definido com aspas

				cNatureza := &(SuperGetMV("MV_NATTEF"))

			EndIf

		Case AllTrim(cFormaPgto) == "CO"

			Natureza := &(SuperGetMV("MV_NATCONV"))

		Case AllTrim(cFormaPgto) == "FI"
			cNatureza := &(SuperGetMV("MV_NATFIN"))

		EndCase

		DbSelectArea("SA6")
		SA6->(DbSetOrder(1)) //A6_FILIAL+A6_COD

		DbSelectArea("SA1")
		SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA

		//Executa a inclusao do titulo a receber |
		For nI := 1 To Len(aParcelas)

			If SA6->(DbSeek(xFilial("SA6") + cPortado))
				cAgeDep		:= SA6->A6_AGENCIA
				cConta		:= SA6->A6_NUMCON
			Endif

			If SA1->(DbSeek(xFilial("SA1")+PadR(aParcelas[nI][5],TamSX3("A1_COD")[1])+aParcelas[nI][6]))
				FwLogMsg("INFO",, "REST", FunName(), "", "01", "Posicionou no cliente", 0, (Seconds() - nStart), {})
			Else
				FwLogMsg("ERROR",, "REST", FunName(), "", "01", "Nao posicionou no cliente", 0, (Seconds() - nStart), {})
			Endif

			aSE1 := {		{"E1_FILIAL"	,	xFilial("SE1")					,Nil},;
				{"E1_PREFIXO"	,	cPrefixo						,Nil},;
				{"E1_NUM"	  	,	cNumTitulo						,Nil},;
				{"E1_PARCELA" 	,	aParcelas[nI][4] 				,Nil},;
				{"E1_TIPO"	 	,	AllTrim(cFormaPgto)				,Nil},;
				{"E1_NATUREZ" 	,	cNatureza						,Nil},;
				{"E1_PORTADO" 	,	cPortado						,Nil},;
				{"E1_CLIENTE" 	,	PadR(aParcelas[nI][5],TamSX3("A1_COD")[1])				,Nil},;
				{"E1_LOJA"	  	,	aParcelas[nI][6]				,Nil},;
				{"E1_EMISSAO" 	,	dDtReceb						,Nil},;
				{"E1_VENCTO"  	,	aParcelas[nI][3]				,Nil},;
				{"E1_VENCREA" 	,	DataValida(aParcelas[nI][3])	,Nil},;
				{"E1_MOEDA" 	,	1								,Nil},;
				{"E1_ORIGEM"	,	"RECEBIMENTO MOBILE"			,Nil},;
				{"E1_FLUXO"		,	"S"								,Nil},;
				{"E1_VALOR"	  	,	aParcelas[nI][1]				,Nil},;
				{"E1_VLRREAL"  	,	aParcelas[nI][2]				,Nil},;
				{"E1_HIST"		,	""								,Nil},;
				{"E1_BCOCHQ" 	,	cBcoChq							,Nil},;
				{"E1_AGECHQ" 	,	cAgeChq							,Nil},;
				{"E1_CTACHQ" 	,	cContaChq						,Nil},;
				{"E1_NSUTEF"  	,	aFPagto[11]						,Nil},;
				{"E1_CARTAUT"  	,	aFPagto[12]						,Nil}}

			MsExecAuto({|x,y| Fina040(x,y)},aSE1,3) //Inclusao

			If lMsErroAuto
				Alert("Falha na inclusao do Titulo a Receber")
				MostraErro()
				DisarmTransaction()
				lRet := .F.
				Exit
			Else
				//Gravamos as informacoes do titulo gerado na tabela MDN(Log de Titulos Gerados)|
				aMDN := { 	{"MDN_FILIAL"	, xFilial("MDN")	},;
					{"MDN_GRFILI"	, xFilial("SE1")	},;
					{"MDN_PREFIX"	, cPrefixo			},;
					{"MDN_NUM"		, cNumTitulo		},;
					{"MDN_PARCEL"	, AllTrim(Str(nI))	},;
					{"MDN_TIPO"		, cFormaPgto		},;
					{"MDN_LOTE"		, cLoteBx			} ;
					}

				//Grava informacoes dos titulos a receber gerados
				RecLock("MDN" , .T.)
				For nX := 1 to Len(aMDN)
					REPLACE &("MDN->" + aMDN[nX][1]) WITH aMDN[nX][2]
				Next nX
				MDN->( MsUnlock() )

				// se o parametro estiver habilitado para geraï¿½ï¿½o
				// do contas a pagar para a administradora financeira
				If lMvLjGerTx .AND. AllTrim(cFormaPgto) $ "CC|CD"

					// inclui Administradora como Fornecedor
					cCodFornec := L070IncSA2()	//retorna o coigo do Fornecedor(SA2)

					// se o fornecedor jï¿½ existe ou foi criado com sucesso
					If !Empty(cCodFornec)

						// calculo a taxa a ser paga
						nValorTaxa := A410Arred((aParcelas[nI][2] * nTaxa) / 100, "L2_VRUNIT")

						aVetorSE2 :={	{"E2_PREFIXO"	, SE1->E1_PREFIXO		, Nil}	,;
							{"E2_NUM"	   	, SE1->E1_NUM    		, Nil}	,;
							{"E2_PARCELA"	, SE1->E1_PARCELA		, Nil}	,;
							{"E2_TIPO"		, SE1->E1_TIPO   		, Nil}	,;
							{"E2_NATUREZ"	, SE1->E1_NATUREZ		, Nil}	,;
							{"E2_FORNECE"	, cCodFornec 			, Nil}	,;
							{"E2_LOJA"		, SE1->E1_LOJA   		, Nil}	,;
							{"E2_EMISSAO"	, dDtReceb      		, NIL}	,;
							{"E2_VENCTO"	, SE1->E1_VENCTO 		, NIL}	,;
							{"E2_VENCREA"	, SE1->E1_VENCREA		, NIL}	,;
							{"E2_VALOR"		, nValorTaxa 			, NIL}	,;
							{"E2_HIST"		, AllTrim(SE1->E1_NUM)	, NIL}	}

						MSExecAuto( {|x,y,z| FINA050(x,y,z)}, aVetorSE2, Nil, 3 )

						// Verifica se houve algum erro durante a execucao da rotina automatica
						If lMsErroAuto
							Alert("Falha na inclusao do Titulo a Pagar")
							MostraErro()
							DisarmTransaction()
							lRet := .F.
							Exit
						EndIf
					Endif
				EndIf

				If AllTrim(cFormaPgto) $ "CH"

					//Gravamos os dados do Cheque
					LJRecGrvCH(cBcoChq, cAgeChq, cContaChq, cPortado, aParcelas[nI][1], aParcelas[nI][3], "", "", Space(TamSX3("EF_TEL")[1]),;
						.F., cPrefixo, cNumTitulo,	aParcelas[nI][4], cFormaPgto, aParcelas[nI][5], aParcelas[nI][6])
				EndIf
			EndIf
		Next nI

	else

		DisarmTransaction()
		lRet := .F.

	endif

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc} LJCriaParcelas
Funcao que cria as parcelas da forma de pagamento
@param   cFormaPgto	Forma de pagamento
@param   nTotal		Total do pagamento
@param   dData		Data do pagamento
@param   nQtdParc	Quantidade de parcelas
@param   cCodAdm	Codigo da administradora financeira
@author  Vendas & CRM
@version P11.5
@since   27/06/2012
@return  aParcelas	Array de parcelas a serem gravadas
/*/
//--------------------------------------------------------
Static Function LJCriaParcelas(cFormaPgto, nTotal, dData, nQtdParc,cCodAdm,cBandeira,cLogError)

	Local nTamE1Dup 	:= TamSX3("E1_PARCELA")[1]	// Tamanho do campo no SX3
	Local aParcelas		:= {}						// Array de parcelas do pagamento
	Local aArea			:= {}						// Armazena a area ativa
	Local nVlrSobra		:= 0						// Resto do total apos ter dividido as parcelas
	Local nVlrParc		:= 0						// Valor de cada parcela
	Local nVlrReal		:= 0						// Valor Real sem as taxas cobradas pela administradora financeira
	Local nTaxa	 		:= 0						// Taxa cobrada pela Adm.Fin.
	Local nDias	 		:= 0						// Data com a adicao de dias da virada do recebimento
	Local cCodCli		:= SA1->A1_COD				// Codigo do cliente
	Local cLojCli		:= SA1->A1_LOJA				// Loja do cliente
	Local cNomeCli		:= SA1->A1_NOME				// Nome do cliente
	Local nI			:= 0						// Contador do For
	Local lContinua	:= .T.

	Local lMvLjGerTx	:= SuperGetMV( "MV_LJGERTX",, .F. )
	Local aAdmValTax	:= {}
	Local nValorTaxa	:= 0

	Local nStart		:= Seconds()

	Default cCodAdm		:= ""
	Default cBandeira	:= ""
	Default cFormaPgto 	:= "R$"
	Default nTotal	 	:= 0
	Default dData 	 	:= DDATABASE
	Default nQtdParc 	:= 1
	Default cLogError	:= ""

	//|		-ESTRUTURA aParcelas-		|
	//|aParcelas[1] VALOR PARCELA		|
	//|aParcelas[2] VALOR REAL			|
	//|aParcelas[3] DATA DE VENCIMENTO	|
	//|aParcelas[4] PARCELA				|
	//|aParcelas[5] COD. CLIENTE		|
	//|aParcelas[6] LOJA CLIENTE		|
	//|aParcelas[7] NOME CLIENTE		|

	If nQtdParc == 0
		nQtdParc := 1
	EndIf

	If AllTrim(cFormaPgto) $ "CC|CD|FI|CO"

		aArea := GetArea()

		UJT->(DbSetOrder(2))
		UJU->(DbSetOrder(1))

		//Posiciono no cadastro da amarracao Gateway x Bandeira
		if UJT->(DbSeek(xFilial("UJT")+ PADR(cCodAdm,TamSx3("UJT_IDVIND")[1] ) )) .AND. UJT->UJT_STATUS == "A"

			//posiciona na bandeira da gateway
			if UJU->(DbSeek(xFilial("UJU")+UJT->UJT_CODIGO+cBandeira))

				SAE->(DbOrderNickName("IDVINDI"))

				//Posiciono na administradora financeira
				If SAE->(DbSeek(xFilial("SAE")+UJU->UJU_CODIGO+UJU->UJU_ITEM))

					If SAE->AE_FINPRO == "N"

						nDias		:= SAE->AE_DIAS
						//Se a administradora financeira nao estiver cadastrada
						//como cliente a funcao L070IncSAI a inclui
						L070IncSA1()
						cCodCLi		:= SAE->AE_COD
						cLojCli		:= "01"
						cNomeCli	:= SAE->AE_DESC
					EndIf

					///////////////////////////////////////////////////////////////////////
					//Chamada da rotina LJ7_TxAdm para calculo da taxa da Adm Financeira  //
					//de acordo com o cadastrado na tabela MEN							  //
					//Par?etros utilizados:						    					  //
					// 1 - Quantidade de parcelas					  					  //
					// 2 - Valor total das parcelas					 					  //
					///////////////////////////////////////////////////////////////////////
					aAdmValTax := LJ7_TxAdm(SAE->AE_COD,nQtdParc,nTotal)

					nTaxa := Iif(aAdmValTax[03] > 0,aAdmValTax[03],SAE->AE_TAXA)

					// se o parametro MV_LJGERTX estiver do, ï¿½ descontada a taxa da Administradora Financeira
					// na inclusï¿½o do tï¿½tulo a receber contra a Administradora
					// se estiver habiltiado, serï¿½ gerado um contas a pagar contra a Administradora
					If lMvLjGerTx
						nValorTaxa := 0
					Else
						nValorTaxa := (nTotal * nTaxa) / 100
					EndIf
				endif
			else

				lContinua := .F.
				cLogError := "LJCriaParcelas - Bandeira nao foi localizada na amarracao Gateway x Bandeira"
				FwLogMsg("ERROR",, "REST", FunName(), "", "01", cLogError, 0, (Seconds() - nStart), {})

			endif
		Else
			lContinua := .F.
			cLogError := "LJCriaParcelas - Gateway nao foi localizada na amarracao Gateway x Bandeira"
			FwLogMsg("ERROR",, "REST", FunName(), "", "01", cLogError, 0, (Seconds() - nStart), {})
		EndIf

		RestArea(aArea)
	EndIf

	if lContinua
		
		//realizo a deducao da taxa administrativa
		nVlrReal	:= nTotal - nValorTaxa

		//valor da parcela contra a administradora
		nVlrParc 	:= Round((nVlrReal / nQtdParc),2) 

		//valor de sobra pra adicionar na ultima parcela
		nVlrSobra 	:= nVlrReal - (nVlrParc * nQtdParc)

		// Data com a adicao de dias da virada do recebimento
		dData 		+= nDias

		For nI := 1 To nQtdParc

			//A partir da segunda parcela, adicionamos 30d a data de cada parcela?
			If nI > 1
				dData += 30
			EndIf

			//Adicionamos a sobra ao valor da ultima parcela
			If nI == nQtdParc
				nVlrParc += nVlrSobra
			EndIf

			Aadd( aParcelas,{nVlrParc   		,;
							nVlrReal			,;
							dData				,;
							PadL(nI, nTamE1Dup)	,;
							cCodCli				,;
							cLojCli				,;
							cNomeCli			})

		Next nI

	endif

Return aParcelas

/**************************************/
Static Function CarBenFun(cPortb,dData)
	/**************************************/

	Local dRet 		:= CTOD("  /  /    ")
	Local cTpPortab	:= "2"
	Local nMesBenef	:= SuperGetMV("MV_XCARBEN",,3) // quantidade de meses de carï¿½ncia do beneficiï¿½rio

	// se o contrato for de portabilidade
	// a data de carï¿½ncia ï¿½ a mesma data do contrato
	if cPortb == cTpPortab
		dRet := dData
	else
		// serï¿½ calculada a carï¿½ncia somando X meses ï¿½ data de inclusï¿½o do beneficiï¿½rio
		dRet := MonthSum(dDataBase,nMesBenef)
	endif

Return(dRet)

/*###########################################################################
#############################################################################
## Programa  | RecAdesao | Autor | Wellington Gonï¿½alves  | Data|28/03/2019 ##
##=========================================================================##
## Desc.     | Funï¿½ï¿½o que faz o recebiento da Taxa de Adesao			   ##
##=========================================================================##
## Uso       | Pï¿½stumos		                                               ##
#############################################################################
###########################################################################*/

Static Function RecAdesao(cPrefFun,cContrato,cTipoFun,dDataRec,cVendedor,nDesconto,aFPagto,cLogError)

	Local aArea			:= GetArea()
	Local aTitulo		:= {}
	Local cQry			:= ""
	Local cSequenciaE5	:= ""
	Local cLoteBx		:= ""
	Local lRet 			:= .F.
	Local nTamMDNLt		:= TamSx3("MDN_LOTE")[1]
	Local nZ			:= 1
	Local nStart		:= Seconds()

	//Posiciona no titulo a receber de entrada
	If Select("QRYSE1") > 0
		QRYSE1->(DbCloseArea())
	Endif

	cQry := " SELECT "
	cQry += " TOP 1 "
	cQry += " SE1.E1_PREFIXO, "
	cQry += " SE1.E1_NUM, "
	cQry += " SE1.E1_PARCELA, "
	cQry += " SE1.E1_TIPO, "
	cQry += " SE1.E1_VENCTO, "
	cQry += " SE1.E1_VALOR, "
	cQry += " SE1.E1_MULTA, "
	cQry += " SE1.E1_JUROS, "
	cQry += " SE1.E1_DESCONT "
	cQry += " FROM "
	cQry += " " +RetSqlName("SE1") + " SE1 "
	cQry += " WHERE "
	cQry += " SE1.D_E_L_E_T_ 		<> '*' "
	cQry += " AND SE1.E1_FILIAL 	= '" + xFilial("SE1") + "'"
	cQry += " AND SE1.E1_PREFIXO 	= '" + cPrefFun + "'"
	cQry += " AND SE1.E1_NUM 		= '" + cContrato + "'"
	cQry += " AND SE1.E1_PARCELA 	= '" + StrZero(1,TamSX3("E1_PARCELA")[1]) + "'"
	cQry += " AND SE1.E1_TIPO	 	= '" + cTipoFun + "'"
	cQry += " AND SE1.E1_SALDO	 	> 0 "

	cQry := ChangeQuery(cQry)
	TcQuery cQry NEW Alias "QRYSE1"

	If QRYSE1->(!EOF())

		aTitulo := {}

		SE1->(DbSetOrder(1)) // E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
		if SE1->(DbSeek(xFilial("SE1") + QRYSE1->E1_PREFIXO + QRYSE1->E1_NUM + QRYSE1->E1_PARCELA + QRYSE1->E1_TIPO))

			AAdd(aTitulo , SE1->E1_NUM			) // Numero
			AAdd(aTitulo , SE1->E1_PARCELA		) // Parcela
			AAdd(aTitulo , SE1->E1_VENCTO		) // Vencimento
			AAdd(aTitulo , SE1->E1_VALOR		) // Valor
			AAdd(aTitulo , SE1->E1_MULTA		) // Multa
			AAdd(aTitulo , SE1->E1_JUROS		) // Juros
			AAdd(aTitulo , nDesconto			) // Desconto
			AAdd(aTitulo , SE1->E1_VALOR		) // Valor recebido
			AAdd(aTitulo , ""					) // Forma de pagamento
			AAdd(aTitulo , 0					) // Valor troco

			if dDataRec < SE1->E1_EMISSAO
				dDataRec := SE1->E1_EMISSAO
			endif

			// Entrada no caixa
			lRet := U_RecebParc(aTitulo,SE1->E1_CLIENTE,SE1->E1_LOJA,dDataRec,aFPagto,SE1->E1_PREFIXO,SE1->E1_TIPO,cVendedor,cContrato,@cLogError)

			if lRet

				///////////////////////////////////////////////////////////////////////////////////////
				/////// IDENTIFICO O LOTE DA BAIXA PARA GERAR MOVIMENTOS NAS TABELAS MDM E MDN. ///////
				//////////////////////////////////////////////////////////////////////////////////////
				
				//Gera numero do lote somando + 1 no ultimo lote encontrado
				cLoteBx	:= GetSx8Num("MDN","MDN_LOTE",,2)
				
				MDN->(DbSetOrder(2)) // MDN_FILIAL + MDN_LOTE
				While MDN->(DbSeek(xFilial("MDN") + cLoteBx))
					MDN->(ConfirmSX8())
					cLoteBx := GetSx8Num("MDN","MDN_LOTE",,2)
				EndDo
				
				// se ja estiver em uso eu pego um novo numero para o banco de conhecimento
				While !MayIUseCode("MDN"+xFilial("MDN")+cLoteBx )
					cLoteBx := GetSx8Num("MDN","MDN_LOTE",,2)
				EndDo

				//retorna a sequencia da movimentacao gerada na SE5 de acordo com a forma de pagamento
				cSequenciaE5 := RetSequenciaSE5(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO)

				//Gravo Log dos Titulos Baixados
				LogTitulosBaixados(xFilial("SE1"),;		//Filial do Titulo
				SE1->E1_PREFIXO,;	//Prefixo
				SE1->E1_NUM,;		//Numero do Titulo (Num do Contrato)
				SE1->E1_PARCELA,;	//Parcela Baixada
				SE1->E1_TIPO,;		//Tipo da Parcela
				SE1->E1_EMISSAO,;	//Data de Emissao
				cSequenciaE5,;		//Sequecia do Movimento na SE5
				cLoteBx)			//Lote da Baixa

				//caso o pagamento seja em cartao, incluo o titulo contra adm financeira ou Emitente do Cheque
				For nZ := 1 To Len(aFPagto)

					if aFPagto[nZ,1] $ "CH|CC|CD"

						if !(lRet := AdmChqIncluiTitulo(aFPagto[nZ],cVendedor,SE1->E1_NUM,dDataRec,cLoteBx,1,@cLogError))

							
							FwLogMsg("ERROR",, "REST", FunName(), "", "01", "RecAdesao - Nao foi possivel incluir titulo contra a administradora financeira!", 0, (nStart - Seconds()), {})

							Exit

						endif

					endif

				Next nZ

			endif

		else
			cLogError := "RecAdesao - Erro ao posicionar no titulo " + QRYSE1->E1_NUM + " parcela " + QRYSE1->E1_PARCELA
			
			FwLogMsg("ERROR",, "REST", FunName(), "", "01", cLogError, 0, (nStart - Seconds()), {})

		endif

	endif

	If Select("QRYSE1") > 0
		QRYSE1->(DbCloseArea())
	Endif

	RestArea(aArea)

Return(lRet)

/*###########################################################################
#############################################################################
## Programa  | RecAdiant | Autor | Wellington Gonï¿½alves  | Data|28/03/2019 ##
##=========================================================================##
## Desc.     | Funï¿½ï¿½o que faz o recebiento do adiantamento				   ##
##=========================================================================##
## Uso       | Pï¿½stumos		                                               ##
#############################################################################
###########################################################################*/

Static Function RecAdiant(cPrefFun,cContrato,cTipoFun,dDataRec,cVendedor,nQtdParcelas,aFPagto,cLogError)

	Local aArea			:= GetArea()
	Local lRet 			:= .F.
	Local cQry			:= ""
	Local cSequenciaE5	:= ""
	Local cLoteBx		:= ""
	Local lRet 			:= .F.
	Local nTamMDNLt		:= TamSx3("MDN_LOTE")[1]
	Local nZ			:= 1
	Local aTitulo		:= {}
	Local nStart		:= Seconds()

	//Posiciona no titulo a receber de entrada
	If Select("QRYSE1") > 0
		QRYSE1->(DbCloseArea())
	Endif

	cQry := " SELECT "
	cQry += " TOP " + cValToChar(nQtdParcelas) + " "
	cQry += " SE1.E1_PREFIXO, "
	cQry += " SE1.E1_NUM, "
	cQry += " SE1.E1_PARCELA, "
	cQry += " SE1.E1_TIPO, "
	cQry += " SE1.E1_VENCTO, "
	cQry += " SE1.E1_VALOR, "
	cQry += " SE1.E1_MULTA, "
	cQry += " SE1.E1_JUROS, "
	cQry += " SE1.E1_DESCONT "
	cQry += " FROM "
	cQry += " " +RetSqlName("SE1") + " SE1 "
	cQry += " WHERE "
	cQry += " SE1.D_E_L_E_T_ 		<> '*' "
	cQry += " AND SE1.E1_FILIAL 	= '" + xFilial("SE1") + "'"
	cQry += " AND SE1.E1_PREFIXO 	= '" + cPrefFun + "'"
	cQry += " AND SE1.E1_NUM 		= '" + cContrato + "'"
	cQry += " AND SE1.E1_TIPO	 	= '" + cTipoFun + "'"
	cQry += " AND SE1.E1_SALDO	 	> 0 "
	cQry += " ORDER BY SE1.E1_FILIAL, SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA "

	cQry := ChangeQuery(cQry)
	TcQuery cQry NEW Alias "QRYSE1"

	If QRYSE1->(!EOF())

		FwLogMsg("INFO",, "REST", FunName(), "", "01", ">> RecAdiant - Consulta de Titulos retornou registros", 0, (nStart - Seconds()), {})


		While QRYSE1->(!EOF())

			aTitulo := {}

			SE1->(DbSetOrder(1)) // E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
			if SE1->(DbSeek(xFilial("SE1") + QRYSE1->E1_PREFIXO + QRYSE1->E1_NUM + QRYSE1->E1_PARCELA + QRYSE1->E1_TIPO))

				AAdd(aTitulo , SE1->E1_NUM			) // Numero
				AAdd(aTitulo , SE1->E1_PARCELA		) // Parcela
				AAdd(aTitulo , SE1->E1_VENCTO		) // Vencimento
				AAdd(aTitulo , SE1->E1_VALOR		) // Valor
				AAdd(aTitulo , SE1->E1_MULTA		) // Multa
				AAdd(aTitulo , SE1->E1_JUROS		) // Juros
				AAdd(aTitulo , SE1->E1_DESCONT		) // Desconto
				AAdd(aTitulo , SE1->E1_VALOR		) // Valor recebido
				AAdd(aTitulo , ""					) // Forma de pagamento
				AAdd(aTitulo , 0					) // Valor troco

				if dDataRec < SE1->E1_EMISSAO
					dDataRec := SE1->E1_EMISSAO
				endif

				// Entrada no caixa - Baixa
				lRet := U_RecebParc(aTitulo,SE1->E1_CLIENTE,SE1->E1_LOJA,dDataRec,aFPagto,SE1->E1_PREFIXO,SE1->E1_TIPO,cVendedor,cContrato,@cLogError)

				///////////////////////////////////////////////////////////////////////////////////////
				/////// IDENTIFICO O LOTE DA BAIXA PARA GERAR MOVIMENTOS NAS TABELAS MDM E MDN ///////
				//////////////////////////////////////////////////////////////////////////////////////
				if lRet .And. Empty(cLoteBx)

					//Gera numero do lote somando + 1 no ultimo lote encontrado
					cLoteBx	:= GetSx8Num("MDN","MDN_LOTE",,2)
					
					MDN->(DbSetOrder(2)) // MDN_FILIAL + MDN_LOTE
					While MDN->(DbSeek(xFilial("MDN") + cLoteBx))
						MDN->(ConfirmSX8())
						cLoteBx := GetSx8Num("MDN","MDN_LOTE",,2)
					EndDo
					
					// se ja estiver em uso eu pego um novo numero para o banco de conhecimento
					While !MayIUseCode("MDN"+xFilial("MDN")+cLoteBx )
						cLoteBx := GetSx8Num("MDN","MDN_LOTE",,2)
					EndDo
					//retorna a sequencia da movimentacao gerada na SE5 de acordo com a forma de pagamento
					cSequenciaE5 := RetSequenciaSE5(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO)

				endif

				if lRet

					//Gravo Log dos Titulos Baixados
					LogTitulosBaixados(xFilial("SE1"),;		//Filial do Titulo
					SE1->E1_PREFIXO,;	//Prefixo
					SE1->E1_NUM,;		//Numero do Titulo (Num do Contrato)
					SE1->E1_PARCELA,;	//Parcela Baixada
					SE1->E1_TIPO,;		//Tipo da Parcela
					SE1->E1_EMISSAO,;	//Data de Emissao
					cSequenciaE5,;		//Sequecia do Movimento na SE5
					cLoteBx)			//Lote da Baixa

					FwLogMsg("INFO",, "REST", FunName(), "", "01", " >> RecAdiant - Parcela recebida com sucesso " + QRYSE1->E1_PARCELA, 0, (nStart - Seconds()), {})

				else
					
					cLogError := "RecAdiant - Nao foi possivel receber parcela " + QRYSE1->E1_PARCELA
					
					FwLogMsg("ERROR",, "REST", FunName(), "", "01", cLogError, 0, (nStart - Seconds()), {})
					Exit

				endif

			else
				cLogError:= "RecAdiant - Erro ao posicionar no titulo " + QRYSE1->E1_NUM + " parcela " + QRYSE1->E1_PARCELA
				
				FwLogMsg("ERROR",, "REST", FunName(), "", "01", cLogError, 0, (nStart - Seconds()), {})
	
			endif

			QRYSE1->(DbSkip())

		EndDo

		//caso o pagamento seja em cartao, incluo o titulo contra adm financeira ou Emitente do Cheque
		For nZ := 1 To Len(aFPagto)

			if aFPagto[nZ,1] $ "CH|CC|CD"

				if !(lRet := AdmChqIncluiTitulo(aFPagto[nZ],cVendedor,cContrato,dDataRec,cLoteBx,nQtdParcelas,@cLogError))

					FwLogMsg("ERROR",, "REST", FunName(), "", "01", ">> Nao foi possivel incluir titulo contra a administradora financeira!", 0, (nStart - Seconds()), {})
					Exit

				endif

			endif

		Next nZ

	else
		
		FwLogMsg("ERROR",, "REST", FunName(), "", "01", " >> RecAdiant - Consulta de titulos nao retornou registros", 0, (nStart - Seconds()), {})

	endif

	If Select("QRYSE1") > 0
		QRYSE1->(DbCloseArea())
	Endif

	RestArea(aArea)

Return(lRet)

/*###########################################################################
#############################################################################
## Programa  | AdmChqIncluiTitulo | Autor | Raphael Martins Data|28/03/2019##
##=========================================================================##
## Desc.     | Funcao para Gravar o Log de Titulos Baixados e Inclusao de  ##
## 			   Titulo contra a Adm Financeira							   ##
##=========================================================================##
## Uso       | Pï¿½stumos		                                               ##
#############################################################################
###########################################################################*/

Static Function AdmChqIncluiTitulo(aFormaPgto,cVendedor,cContrato,dRecebimento,cLoteBx,nQtdParcelas,cLogError)

	Local aArea 		:= GetArea()
	Local aAreaSE1		:= SE1->(GetArea())
	Local cCaixaVend	:= ""
	Local lRet			:= .T.
	Local nStart		:= Seconds()

	//retorno o caixa do vendedor
	cCaixaVend := U_UxNumCx(cVendedor)

	//realizo a inclusao do Titulo contra a Adm
	if !ULjIncTitRec(aFormaPgto,cCaixaVend,cLoteBx,dRecebimento,cVendedor,cContrato,nQtdParcelas,@cLogError)

		FwLogMsg("ERROR",, "REST", FunName(), "", "01", "Falha na inclusao do titulo a receber", 0, (nStart - Seconds()), {})

		lRet := .F.

	endIf

	RestArea(aArea)
	RestArea(aAreaSE1)

Return(lRet)

/*###########################################################################
#############################################################################
## Programa  | RetSequenciaSE5 | Autor | Raphael Martins Data|28/03/2019   ##
##=========================================================================##
## Desc.     | Funcao para Retornar Sequencia do Movimento gerado na SE5   ##
## 			   															   ##
##=========================================================================##
## Uso       | Pï¿½stumos		                                               ##
#############################################################################
###########################################################################*/

Static Function RetSequenciaSE5(cPrefixo,cTitulo,cParcela,cTipo)

	Local aArea			:= GetArea()
	Local cQry 			:= ""
	Local cSequencia	:= ""

	cQry := " SELECT "
	cQry += " MAX(E5_SEQ) SEQUENCIA "
	cQry += " FROM "
	cQry += RetSQLName("SE5")
	cQry += " WHERE "
	cQry += " D_E_L_E_T_ = ' ' "
	cQry += " AND E5_FILIAL		= '" + xFilial("SE5") + "' "
	cQry += " AND E5_PREFIXO	= '" + cPrefixo+ "'  "
	cQry += " AND E5_NUMERO		= '" + cTitulo + "' "
	cQry += " AND E5_PARCELA	= '" + cParcela + "' "
	cQry += " AND E5_TIPO		= '" + cTipo + "' "

	if Select("QRYSE5") > 0

		QRYSE5->(DbCloseArea() )

	endif

	cQry := ChangeQuery(cQry)

	TcQuery cQry NEW Alias "QRYSE5"

	if QRYSE5->(!Eof())

		cSequencia := QRYSE5->SEQUENCIA

	endif

	QRYSE5->(DbCloseArea())

	RestArea(aArea)

Return(cSequencia)

/*###########################################################################
#############################################################################
## Programa  | LogTitulosBaixados 	   | Raphael Martins Data|28/03/2019   ##
##=========================================================================##
## Desc.     |Funcao para Gravar Log de Titulos Baixados 				   ##
## 			   															   ##
##=========================================================================##
## Uso       | Pï¿½stumos		                                               ##
#############################################################################
###########################################################################*/

Static Function LogTitulosBaixados(cFilTitulo,cPrefixo,cTitulo,cParcela,cTipo,dEmissao,cSequencia,cLoteBx)

	Local aArea := GetArea()

	RecLock("MDM", .T.)

	MDM->MDM_FILIAL		:= xFilial( "MDM" )
	MDM->MDM_BXFILI		:= cFilTitulo
	MDM->MDM_PREFIX		:= cPrefixo
	MDM->MDM_NUM		:= cTitulo
	MDM->MDM_PARCEL		:= cParcela
	MDM->MDM_TIPO		:= cTipo
	MDM->MDM_SEQ		:= cSequencia
	MDM->MDM_DATA		:= dEmissao
	MDM->MDM_LOTE		:= cLoteBx
	MDM->MDM_ESTORN		:= "2"

	MDM->(MsUnlock())
	
	MDN->(ConfirmSX8())
	
	RestArea(aArea)

Return()

/*/{Protheus.doc} RUTILE14
pega proximo numero disponivel para sequencia
@author TOTVS
@since 08/05/2019
@version P12
@param Nao recebe parametros
@return nulo
/*/
User function UObjProxCod()

	Local cQSEQ 	:= ""
	Local cProximo	:= ""
	Local nProximo	:= 0
	
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


/*/{Protheus.doc} RUTILE14
Validacao do json retornado pelo virtus
@author TOTVS
@since 08/05/2019
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function checkJsonRet(cFormaPgto,oDadosRecor,cCpfCnjp,cLogError)

Local lRet 		:= .T.
Local aAreaU60 	:= U60->(GetArea())
Local nStart	:= Seconds()

U60->(DbSetOrder(2))

//Valido se forma de pagamento é recorrencia
if U60->(DbSeek(xFilial("U60") + cFormaPgto))

	//Valido se Id cliente foi localizado
	If Empty(oDadosRecor:idClienteVindi)

		cLogError := "Id Vindi do cliente " + cCpfCnjp + " nao foi localizado no json""
		
		FwLogMsg("ERROR",, "REST", FunName(), "", "01", cLogError, 0, (Seconds() - nStart), {})
		lRet := .F.

	Elseif Empty(oDadosRecor:idPerfilPgto)

		cLogError := "Perfil de Pagamento do cliente " + cCpfCnjp + " nao foi localizado no json"
		FwLogMsg("ERROR",, "REST", FunName(), "", "01", cLogError, 0, (Seconds() - nStart), {})

		lRet := .F.
	
	ElseIf VfRecorr( AllTrim(cCpfCnjp) )
		cLogError := "Cliente " + cCpfCnjp + " ja tem contrato em recorrencia ativo"
		FwLogMsg("ERROR",, "REST", FunName(), "", "01", cLogError, 0, (Seconds() - nStart), {})

		lRet := .F.

	Endif
Endif

RestArea(aAreaU60)

Return lRet

/*/{Protheus.doc} VfRecorr
Verifica se existe contrato em recorrência para cliente
@type function
@version 12.1.25
@author nata.queiroz
@since 24/04/2020
@param cCpfCnjp, character, CPF do cliente
@return lRet, logical
/*/
Static Function VfRecorr(cCpfCnjp)
	Local lRet := .F.
	Local aAreaSA1 := SA1->( GetArea() )

	SA1->( dbSetOrder(3) ) //-- A1_FILIAL+A1_CGC
	If SA1->( MsSeek(xFilial("SA1") + cCpfCnjp) )
		//-- Verifica se existe contrato em recorrência ativo para cliente
		If .Not. U_RecNaoExist( SA1->A1_COD, SA1->A1_LOJA)
			lRet := .T.
		EndIf
	EndIf

	RestArea(aAreaSA1)

Return lRet

/*/{Protheus.doc} AnexaArq
Funcao para gerar pendencia de sincronizacao
@author TOTVS
@since 08/05/2020
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function AnexaArq(cIdMobile,cPathImg,cIdImagem,cDescricao,cEntidade,cCodEnt)

	Local aArea := GetArea()

	//-- DESCONTINUADO (Tabela para regras de desconto)
	// UJZ->(DbSetOrder(1)) //UJZ_FILIAL+UJZ_IDMOBI+UJZ_ENTIDA+UJZ_NOMARQ

	// if !UJZ->(DbSeek( xFilial("UJZ") + cIdMobile + cEntidade + cIdImagem ))

	// 	RecLock("UJZ",.T.)

	// 	UJZ->UJZ_FILIAL := xFilial("UJZ")
	// 	UJZ->UJZ_IDMOBI := cIdMobile
	// 	UJZ->UJZ_ENTIDA	:= cEntidade
	// 	UJZ->UJZ_CONTRA	:= cCodEnt
	// 	UJZ->UJZ_URL	:= cPathImg
	// 	UJZ->UJZ_SINCRO := "N"
	// 	UJZ->UJZ_NOMARQ	:= cIdImagem
	// 	UJZ->UJZ_DESCRI	:= cDescricao
	// 	UJZ->UJZ_DTINC	:= Date()
	// 	UJZ->UJZ_HRINC	:= Time()

	// 	UJZ->(MsUnlock())

	// endif

	RestArea(aArea)

Return()
