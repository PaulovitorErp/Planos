#Include "protheus.CH"
#include "topconn.ch"  

/*/{Protheus.doc} RIMPM003
Rotina de Processamento de Importacoes 
de clientes
@author Raphael Martins
@since 30/11/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
User Function RIMPM004(aClientes,nHdlLog)

Local aArea 		:= GetArea()
Local aAreaSA1		:= SA1->(GetArea())
Local aDadosCli		:= {}
Local lRet			:= .F.
Local nX			:= 0
Local nPosCNPJ		:= 0
Local cCnpj			:= ""
Local cErroExec		:= ""
Local cPulaLinha	:= Chr(13) + Chr(10)
Local cDirLogServer	:= ""
Local cArqLog		:= "log_imp.log"
Local nJ			:= 1


// variavel interna da rotina automatica
Private lMsErroAuto := .F. 
Private lMsHelpAuto := .F.

//diretorio no server que sera salvo o retorno do execauto
cDirLogServer := GetPvProfString(GetEnvServer(),"StartPath","ERROR",GetAdv97())
cDirLogServer += If(Right(cDirLogServer, 1) <> "\", "\", "") 

SetFunName("MATA030")

For nX := 1 To Len(aClientes)
	
	Begin Transaction 
	
		SA1->(DBSetOrder(3)) //A1_FILIAL + A1_CGC
		
		aLinhaCli	:= aClone(aClientes[nX])
		
		nPosCNPJ:= AScan(aLinhaCli,{|x| AllTrim(x[1]) == "A1_CGC"})
		
		//importo apenas clientes com cnpj
		if nPosCNPJ > 0 
		
			cCnpj		:= Alltrim(aLinhaCli[nPosCNPJ,2])
			
			if !Empty(cCnpj)
			
				//verifico se o cnpj do cliente ja possui no sistema 
				if !SA1->( DbSeek( xFilial("SA1") + cCnpj) )
					
					DbSelectArea("SA1")
					SA1->( DbSetOrder(1) ) //A1_FILIAL + A1_COD + A1_LOJA
					
					//monto array com os dados do cliente
					For nJ := 1 To Len(aLinhaCli)
				
						aAdd(aDadosCli, {Alltrim(aLinhaCli[nJ,1]),	aLinhaCli[nJ,2],NIL})
					
					Next nJ
					
					//incluo o cliente 
					MsExecAuto({|x, y| MATA030(x, y)}, aDadosCli, 3)
					
					If lMsErroAuto
						
						//verifico se arquivo de log existe 
						if nHdlLog > 0 
						
							cErroExec := MostraErro(cDirLogServer + cArqLog )
							
							FErase(cDirLogServer + cArqLog )
								
							fWrite(nHdlLog , "Erro na Inclusao do Cliente:" )
							
							fWrite(nHdlLog , cPulaLinha )
						
							fWrite(nHdlLog , cErroExec )
						
							fWrite(nHdlLog , cPulaLinha )
						
						endif
						
										
						DisarmTransaction()
						SA1->( RollBackSX8() )
						
					else
						
						//verifico se arquivo de log existe 
						if nHdlLog > 0 
						
							fWrite(nHdlLog , "Cliente Cadastrado com sucesso!" )
						
							fWrite(nHdlLog , cPulaLinha )
						
							fWrite(nHdlLog , "Codigo/Loja: " + Alltrim(SA1->A1_COD) + "/" + Alltrim(SA1->A1_LOJA) )
						
							fWrite(nHdlLog , cPulaLinha )
							
							lRet := .T.
							
						endif
						
						SA1->( ConfirmSX8() )
								
					endif
					
				else
					
					//verifico se arquivo de log existe 
					if nHdlLog > 0 
								
						fWrite(nHdlLog , "Cpf/Cnpj: " + Alltrim(cCnpj) + " já cadastrado na base de dados! " )
						
						fWrite(nHdlLog , cPulaLinha )
					
					endif
					
				endif
			
			else
				
				fWrite(nHdlLog , "Cliente sem CPF/CNPJ preenchido, campo obrigatório para a importação!" )
						
				fWrite(nHdlLog , cPulaLinha )
				
			endif
			
		else
			
			fWrite(nHdlLog , "Layout de importação não possui campo CPF/CNPJ, a definição do mesmo é obrigatória!" )
						
			fWrite(nHdlLog , cPulaLinha )
					
			
		endif
	
	End Transaction 

Next nX 


RestArea(aArea)
RestArea(aAreaSA1)

Return(lRet)