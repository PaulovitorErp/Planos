#Include "protheus.CH"
#include "topconn.ch"  

/*/{Protheus.doc} RIMPF005
Rotina de Importacao de Produtos
Funeraria
@author Raphael Martins
@since 18/12/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
User function RIMPF005(aProdutos,nHdlLog)

Local aArea 			:= GetArea()
Local aAreaUF2			:= UF2->(GetArea())
Local aAreaUF3			:= UF3->(GetArea())
Local aContrato			:= {}
Local aLinhaProd		:= {}
Local aMergeProd		:= {}
Local lRet				:= .F.
Local nX				:= 0
Local nPosLeg			:= 0
Local cCodLeg			:= ""
Local cErroExec			:= ""
Local cProduto			:= ""
Local cPulaLinha		:= Chr(13) + Chr(10)
Local cDirLogServer		:= ""
Local cArqLog			:= "log_imp.log"
Local dDataBkp			:= dDatabase

//diretorio no server que sera salvo o retorno do execauto
cDirLogServer := GetPvProfString(GetEnvServer(),"StartPath","ERROR",GetAdv97())
cDirLogServer += If(Right(cDirLogServer, 1) <> "\", "\", "") 

SetFunName("RFUNA002")

For nX := 1 To Len(aProdutos)
	
	Begin Transaction 
	
		UF2->(DbOrderNickName("UF2_XCODAN")) //UF2_FILIAL+UF2_CODANT
		
		aLinhaProd	:= aClone(aProdutos[nX])
		
		//posicao do campo de codigo legado
		nPosLeg			:= AScan(aLinhaProd,{|x| AllTrim(x[1]) == "COD_ANT"})
		nPosProd		:= AScan(aLinhaProd,{|x| AllTrim(x[1]) == "UF3_PROD"})
		
		//importo apenas produtos de contratos com codigo legado
		if nPosLeg > 0 .And. nPosProd > 0 
		
			cCodLeg 	:= Alltrim(aLinhaProd[nPosLeg,2])
			cProduto	:= Alltrim(aLinhaProd[nPosProd,2])
			
			if !Empty(cCodLeg)
				
				//verifico se o contrato ja esta cadastrado sistema 
				if UF2->( DbSeek( xFilial("UF2") + cCodLeg) )
					
					UF3->( DbSetOrder(2) ) //UF3_FILIAL + UF3_CODIGO + UF3_PROD
					
					if !UF3->(DbSeek(xFilial("UF3")+UF2->UF2_CODIGO+cProduto))
						
						DbSelectArea("UF2")
						UF2->( DbSetOrder(1) ) //UF2_FILIAL + UF2_CODIGO
						
						//preenchimento atraves dos campos chaves do layout
						aAdd( aContrato, {'UF2_CODIGO'      , UF2->UF2_CODIGO 	} )
						
						//adiciono os produtos ja existentes
						aMergeProd := AddProdAtuais(UF2->UF2_CODIGO,aLinhaProd,cProduto)
							
						//incluo o contrato 
						If !U_RFUNE002(aContrato,,,4,aMergeProd)
							
							//verifico se arquivo de log existe 
							if nHdlLog > 0 
							
								cErroExec := MostraErro(cDirLogServer + cArqLog )
								
								FErase(cDirLogServer + cArqLog )
									
								fWrite(nHdlLog , "Erro na Inclusao do Produto ao Contrato!" )
								
								fWrite(nHdlLog , cPulaLinha )
							
								fWrite(nHdlLog , cErroExec )
							
								fWrite(nHdlLog , cPulaLinha )
							
							endif
							
											
							DisarmTransaction()
							UF2->( RollBackSX8() )
							
						else
							
							//verifico se arquivo de log existe 
							if nHdlLog > 0 
							
								fWrite(nHdlLog , "Produto vinculado com sucesso ao contrato!" )
							
								fWrite(nHdlLog , cPulaLinha )
							
								fWrite(nHdlLog , "Produto: " + Alltrim(cProduto) )
							
								fWrite(nHdlLog , cPulaLinha )
								
								lRet := .T.
								
							endif
									
						endif
					else
						
						//verifico se arquivo de log existe 
						if nHdlLog > 0 
							
							fWrite(nHdlLog , "Produto: "+ Alltrim(UF3->UF3_PROD) +" ja vinculado ao contrato!" )
						
							fWrite(nHdlLog , cPulaLinha )
			
						endif
					endif
						
				else
						
					//verifico se arquivo de log existe 
					if nHdlLog > 0 
									
						fWrite(nHdlLog , "Contrato: " + Alltrim(cCodLeg) + " nao cadastrado na base de dados! " )
						
						fWrite(nHdlLog , cPulaLinha )
						
					endif
						
				endif
						
			else
				
				//verifico se arquivo de log existe 
				if nHdlLog > 0 
									
					fWrite(nHdlLog , "Contrato sem Codigo Legado preenchido, campo obrigatório para a importação!" )
					
					fWrite(nHdlLog , cPulaLinha )
						
				endif
						
				
			endif
				
		else
			
			//verifico se arquivo de log existe 
			if nHdlLog > 0 
			
				fWrite(nHdlLog , "Layout de importação não possui campo Cod Legado e/ou Cod Produto, a definição do mesmo é obrigatória!" )
						
				fWrite(nHdlLog , cPulaLinha )
			
			endif
			
		endif
		
	End Transaction 
	
Next nX 

RestArea(aArea)
RestArea(aAreaUF2)
RestArea(aAreaUF3)


Return(lRet)

/*/{Protheus.doc} AddProdAtuais
Adiciono os produtos atuais do contrato
@author Raphael Martins
@since 18/12/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function AddProdAtuais(cCodigo,aLinhaProd,cProduto)

Local aArea 			:= GetArea()
Local aAreaUF2			:= UF2->(GetArea())
Local aAreaUF3			:= UF3->(GetArea())
Local cQry 				:= ""
Local cDescProduto		:= ""
Local aItem				:= {}
Local aItens			:= {}
Local nItemUF3			:= 0 

cQry := " SELECT "  
cQry += " UF3_ITEM ITEM, " 
cQry += " UF3_PROD PRODUTO, " 
cQry += " UF3_VLRUNI VLR_UNITARIO, " 
cQry += " UF3_QUANT QUANTIDADE, " 
cQry += " UF3_VLRTOT VLRTOTAL, " 
cQry += " UF3_CTRSLD CTR_SALDO, " 
cQry += " UF3_SALDO SALDO, "
cQry += " UF3_TIPO TIPO " 
cQry += " FROM "
cQry += " " + RetSQLName("UF3") + " " 
cQry += "WHERE " 
cQry += "D_E_L_E_T_ = ' ' "  
cQry += "AND UF3_FILIAL = '" + xFilial("UF3") + "' " 
cQry += "AND UF3_CODIGO = '" + cCodigo + "' " 

If Select("QPROD") > 0 
	QPROD->(DbCloseArea())
endif

TcQuery cQry New Alias "QPROD" 

While QPROD->(!Eof())
	
	aItem := {}
	
	//descricao do produto
	cDescProduto := RetField("SB1",1,xFilial("SB1")+QPROD->PRODUTO,"B1_DESC")
	
	aAdd(aItem, {"UF3_ITEM"		,QPROD->ITEM			} )
	aAdd(aItem, {"UF3_TIPO"		,QPROD->TIPO			} )			
	aAdd(aItem, {"UF3_PROD"		,QPROD->PRODUTO			} )
	aAdd(aItem, {"UF3_DESC"		,cDescProduto			} )
	aAdd(aItem, {"UF3_VLRUNI"	,QPROD->VLR_UNITARIO	} )
	aAdd(aItem, {"UF3_QUANT"	,QPROD->QUANTIDADE		} )
	aAdd(aItem, {"UF3_VLRTOT"	,QPROD->VLRTOTAL		} )
	aAdd(aItem, {"UF3_SALDO"	,QPROD->SALDO			} )
	aAdd(aItem, {"UF3_CTRSLD"	,QPROD->CTR_SALDO		} )
	
	Aadd(aItens,aItem)
				
	QPROD->(DbSkip())
	
	nItemUF3++
	
EndDo

//descricao do produto
cDescProduto := RetField("SB1",1,xFilial("SB1")+cProduto,"B1_DESC")

aAdd( aLinhaProd, {'UF3_ITEM' 	, StrZero(nItemUF3 + 1,TamSx3("UF3_ITEM")[1])	})
aAdd( aLinhaProd, {'UF3_DESC' 	, cDescProduto									})
aAdd( aLinhaProd, {'UF3_TIPO' 	, "ADDITENS.PNG"								})
aAdd( aLinhaProd, {'UF3_CTRSLD' , "N"											})

//adicino a linha da importacao aos itens ja existentes
Aadd(aItens,aLinhaProd)

RestArea(aArea)
RestArea(aAreaUF2)
RestArea(aAreaUF3)

Return(aClone(aItens))
