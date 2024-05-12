#Include 'totvs.ch'
#INCLUDE "topconn.ch"
#INCLUDE "TbiConn.ch"

/*/{Protheus.doc} RCPGA043
Rotina para exclusão de manutenções em lote do cemitério
@type function
@version 
@author g.sampaio
@since 02/03/2020
@return Nil
/*/
User Function RCPGA043()

	Local aArea			:= GetArea()
	Local cPerg 		:= "RCPGA043"
	Local dDataDe		:= CTOD("  /  /    ")
	Local dDataAte		:= CTOD("  /  /    ")
	Local cContratoDe	:= ""
	Local cContratoAte	:= ""
	Local cPlano		:= ""
	Local cIndice		:= ""
	Local lContinua		:= .T.

	// cria as perguntas na SX1
	AjustaSx1(cPerg)

	// enquanto o usuário não cancelar a tela de perguntas
	While lContinua

		// chama a tela de perguntas
		lContinua := Pergunte(cPerg,.T.)

		// verifico se esta tudo certo
		if lContinua

			// preencho os parametros
			dDataDe			:= MV_PAR01
			dDataAte		:= MV_PAR02
			cContratoDe 	:= MV_PAR03
			cContratoAte	:= MV_PAR04
			cPlano			:= MV_PAR05
			cIndice			:= MV_PAR06

			// pegunto para o usuario se deseja excluir as taxas de locacao
			if MsgYesNo("Deseja realmente excluir as taxas de locacao do nicho/ossuario?")

				// funcao para excluir a taxa de locacao
				MsAguarde( {|| U_RCPGE039(dDataDe,dDataAte,cContratoDe,cContratoAte,cPlano,cIndice)}, "Aguarde", "Exclusão em Lote de Hist.Locação de Nicho...", .F. )

			endif

		endif

	EndDo

	RestArea(aArea)

Return(Nil)

/*/{Protheus.doc} AjustaSX1
Função que cria as perguntas na SX1.	
// cria a tela de perguntas do relatório
@type function
@version 
@author g.sampaio
@since 02/03/2020
@param cPerg, character, param_description
@return return_type, return_description
/*/
Static Function AjustaSX1(cPerg)

	Local aHelpPor	:= {}
	Local aHelpEng	:= {}
	Local aHelpSpa	:= {}

	///////////// Data do reajuste ////////////////
	U_xPutSX1( cPerg, "01","Data da taxa de?","Data da taxa de?","Data da taxa de?","dDataDe","D",8,0,0,"G","","","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
	U_xPutSX1( cPerg, "02","Data da taxa ate?","Data da taxa ate?","Data da taxa ate?","dDataAte","D",8,0,0,"G","","","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

	//////////// Contrato ///////////////
	U_xPutSX1( cPerg, "03","Contrato De?","Contrato De?","Contrato De?","cContratoDe","C",6,0,0,"G","","U00","","","MV_PAR03","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
	U_xPutSX1( cPerg, "04","Contrato Ate?","Contrato Ate?","Contrato Ate?","cContratoAte","C",6,0,0,"G","","U00","","","MV_PAR04","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

	///////////// Plano /////////////////
	U_xPutSX1( cPerg, "05","Plano?","Plano?","Plano?","cPlano","C",99,0,0,"G","","U05MRK","","","MV_PAR05","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

	//////////// Índice ///////////////
	U_xPutSX1( cPerg, "06","Índice?","Índice?","Índice?","cIndice","C",3,0,0,"G","","U22","","","MV_PAR06","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

Return()
