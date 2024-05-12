#Include "protheus.CH"
#include "topconn.ch"  

/*/{Protheus.doc} RIMPF001
Rotina de Processamento de Importacoes 
de Contrato Funerario
@author Raphael Martins
@since 30/11/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
User Function RIMPF001(aContratos,nHdlLog)

Local aArea 			:= GetArea()
Local aAreaUF2			:= UF2->(GetArea())
Local aDadosCt			:= {}
Local aLinhaCt			:= {}
Local lRet				:= .F.
Local nX				:= 0
Local nPosLeg			:= 0
Local cCpfCnpj			:= 0 
Local nPosPrimVencto	:= 0
Local nPosVend			:= 0 
Local cCodLeg			:= ""
Local cErroExec			:= ""
Local nPosCGCCli		:= ""
Local cVendLeg			:= ""
Local cPulaLinha		:= Chr(13) + Chr(10)
Local cDirLogServer		:= ""
Local cArqLog			:= "log_imp.log"
Local dDataBkp			:= dDatabase

// variavel interna da rotina automatica
Private lMsErroAuto := .F. 
Private lMsHelpAuto := .F.

//diretorio no server que sera salvo o retorno do execauto
cDirLogServer := GetPvProfString(GetEnvServer(),"StartPath","ERROR",GetAdv97())
cDirLogServer += If(Right(cDirLogServer, 1) <> "\", "\", "") 

SetFunName("RFUNA002")

For nX := 1 To Len(aContratos)
	
	Begin Transaction 
	
		UF2->(DbOrderNickName("UF2_XCODAN")) //UF2_FILIAL+UF2_CODANT
		
		aLinhaCt	:= aClone(aContratos[nX])
		
		nPosLeg			:= AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UF2_CODANT"})
		nPosCGCCli		:= AScan(aLinhaCt,{|x| AllTrim(x[1]) == "CGC"})	
		nPosPrimVencto	:= AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UF2_PRIMVE"})	
		nPosVend		:= AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UF2_VEND"})
		nPosBenLeg		:= AScan(aLinhaCt,{|x| AllTrim(x[1]) == "BEN_LEG"})
				
		//importo apenas contratos com codigo legado
		if nPosLeg > 0 
		
			cCodLeg 	:= Alltrim(aLinhaCt[nPosLeg,2])
			cCpfCnpj	:= Alltrim(aLinhaCt[nPosCGCCli,2]) 
			dPrimVencto	:= aLinhaCt[nPosPrimVencto,2]
			cVendLeg	:= DeParaVend(aLinhaCt[nPosVend,2])

			if nPosBenLeg >0
				cCodBenLeg	:= Alltrim(aLinhaCt[nPosBenLeg,2]) 
			endif
			
			dDatabase := dPrimVencto
			
			if !Empty(cCodLeg)
				
				SA1->(DbSetOrder(3)) //A1_FILIAL + A1_CGC
				
				if SA1->(DbSeek(xFilial("SA1") + cCpfCnpj ) )
					
					//verifico se possui encontrou o vendedor
					if !Empty(cVendLeg)
						
						//altero para o vendedor do Protheus
						aLinhaCt[nPosVend,2] := cVendLeg
						
						//verifico se o contrato ja esta cadastrado sistema 
						if !UF2->( DbSeek( xFilial("UF2") + cCodLeg) )
						
							DbSelectArea("UF2")
							UF2->( DbSetOrder(1) ) //UF2_FILIAL + UF2_CODIGO
						
							//preenchimento atraves dos campos chaves do layout
							aAdd( aLinhaCt, {'UF2_CLIENT'      , SA1->A1_COD 	} )
							aAdd( aLinhaCt, {'UF2_LOJA'        , SA1->A1_LOJA 	} )
							
							//incluo o contrato 
							If !U_RFUNE002(aLinhaCt,,,3)
							
								//verifico se arquivo de log existe 
								if nHdlLog > 0 
							
									cErroExec := MostraErro(cDirLogServer + cArqLog )
								
									FErase(cDirLogServer + cArqLog )
									
									fWrite(nHdlLog , "Erro na Inclusao do Contrato:" )
								
									fWrite(nHdlLog , cPulaLinha )
							
									fWrite(nHdlLog , cErroExec )
							
									fWrite(nHdlLog , cPulaLinha )
							
								endif
							
											
								DisarmTransaction()
								UF2->( RollBackSX8() )
							
							else
							
								UF4->(DbSetOrder(3))

								//Gravo o codigo do beneficiario no legado no beneficiario da UF4
								if UF4->(DbSeek(xFilial("UF4")+UF2->UF2_CODIGO+SA1->A1_COD+SA1->A1_LOJA )) .AND. !Empty(cCodBenLeg) 

									if RecLock("UF4",.F.)
										UF4->UF4_BENLEG := cCodBenLeg
										UF4->(MsUnLock())
									endif

								endif

								//verifico se arquivo de log existe 
								if nHdlLog > 0 
							
									fWrite(nHdlLog , "Contrato Cadastrado com sucesso!" )
							
									fWrite(nHdlLog , cPulaLinha )
							
									fWrite(nHdlLog , "Codigo: " + Alltrim(UF2->UF2_CODIGO) )
							
									fWrite(nHdlLog , cPulaLinha )
								
									lRet := .T.
								
								endif
							
							
								EndTran()
								
								UF2->( ConfirmSX8() )
									
							endif
						
						else
						
							//verifico se arquivo de log existe 
							if nHdlLog > 0 
									
								fWrite(nHdlLog , "Contrato: " + Alltrim(cCodLeg) + " já cadastrado na base de dados! " )
							
								fWrite(nHdlLog , cPulaLinha )
						
							endif
						
						endif
					
					else
						
						//verifico se arquivo de log existe 
						if nHdlLog > 0 
									
							fWrite(nHdlLog , "Vendedor do Contrato nao encontrado! " )
						
							fWrite(nHdlLog , cPulaLinha )
						
						endif
							
						
					endif
					
				else
				
					//verifico se arquivo de log existe 
					if nHdlLog > 0 
									
						fWrite(nHdlLog , "Cpf/Cnpj: " + Alltrim(cCpfCnpj) + " não cadastrado na base de dados! " )
						
						fWrite(nHdlLog , cPulaLinha )
						
					endif
						
				
				endif
				
			else
				
				fWrite(nHdlLog , "Contrato sem Codigo Legado preenchido, campo obrigatório para a importação!" )
						
				fWrite(nHdlLog , cPulaLinha )
				
			endif
			
		else
			
			fWrite(nHdlLog , "Layout de importação não possui campo Cod Legado, a definição do mesmo é obrigatória!" )
						
			fWrite(nHdlLog , cPulaLinha )
					
			
		endif
		
	End Transaction 
	
Next nX 

//restauro bkp da database do sistema
dDatabase := dDataBkp


RestArea(aArea)
RestArea(aAreaUF2)

Return(lRet)


/*/{Protheus.doc} DeParaVend
Retorna o Vendedor do Protheus
de Acordo com o Legado
@author Raphael Martins
@since 30/11/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function DeParaVend(cVendLeg)

Local aArea			:= GetArea()
Local aAreaSA3		:= SA3->(GetArea())
Local cVendProtheus	:= ""


SA3->(DbOrderNickName("XCODANT")) //A3_FILIAL+A3_CODANT

if SA3->(DbSeek(xFilial("SA3")+Alltrim(cVendLeg)))
	
	cVendProtheus := SA3->A3_COD
	
endif

RestArea(aArea)
RestArea(aAreaSA3)

Return(cVendProtheus)

