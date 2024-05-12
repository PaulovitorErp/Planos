#include "protheus.ch"

/*/{Protheus.doc} RCPGA035
Realiza a inclus�o de Tansferencia de Enderecamentos
@author Raphael Martins 
@since 11/05/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/

/***********************/
User Function RCPGA035()
/***********************/

	Local cFunBkp 	:= Funname()
	Local lContinua	:= .T.

	Do Case

	Case U00->U00_STATUS == "P" //Pr�-cadastro
		lContinua := .F.
		MsgInfo("O Contrato se encontra pr�-cadastrado, opera��o n�o permitida.","Aten��o")


	Case U00->U00_STATUS == "C" //Cancelado
		lContinua := .F.
		MsgInfo("O Contrato se encontra Cancelado, opera��o n�o permitida.","Aten��o")

		//validar se o contrato possui enderecamento
	EndCase

	if lContinua

		INCLUI := .T.
		ALTERA := .F.

		// Altero o nome da rotina para considerar o menu deste MVC
		SetFunName("RCPGA034")

		FWExecView('INCLUIR','RCPGA034',3,,{|| .T. })

		//retorno a funcao em execucao
		SetFunName(cFunBkp)

	endIf

Return(Nil)

