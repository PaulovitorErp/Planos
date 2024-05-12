#include 'protheus.ch'
#include 'parmtype.ch'

#DEFINE CRLF CHR(13)+CHR(10)

/*/{Protheus.doc} FA070CAN
O ponto de entrada FA070CAN sera executado apos
gravacao dos dados de cancelamento no SE1
e antes de estornar os dados do SE5 e de comissao.

(Comissoes de Motoqueiros)
Utilizado para estornar as comissoes de cobradores,
e limpar o campo de cobrador de recebimento do cadastro do titulo.

@type function
@author Pablo Cavalcante
@since 19/05/2016
@version 1.1
@history 08/04/2020 - Marcos Nata
/*/
User Function FA070CAN()
	Local aArea		  	:= GetArea()
	Local aAreaSE1    	:= SE1->(GetArea())
	Local aAreaSE3	  	:= SE3->(GetArea())
	Local lFindAtuSld 	:= FindFunction("AtuSldNat")
	Local lAtuSldNat  	:= lFindAtuSld .AND. AliasInDic("FIV") .AND. AliasInDic("FIW")
	Local cNatCom	  	:= PADR(&(GetNewPar("MV_NATCOM","")),TamSx3("E2_NATUREZ")[1])
	Local nValComis   	:= 0
	Local nStart		:= 0
	Local lFuneraria	:= SuperGetMV("MV_XFUNE",,.F.)
	Local lCemiterio	:= SuperGetMV("MV_XCEMI",,.F.)

	If lCemiterio .Or. lFuneraria

		If !Empty(SE1->E1_XVENDCB)

			SE3->(DbSetOrder(3)) //E3_FILIAL+E3_VEND+E3_CODCLI+E3_LOJA+E3_PREFIXO+E3_NUM+E3_PARCELA+E3_TIPO+E3_SEQ
			If SE3->(DbSeek(xFilial("SE3")+SE1->(E1_XVENDCB+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)))

				While SE3->(!Eof())	.and. SE3->(E3_FILIAL+E3_VEND+E3_CODCLI+E3_LOJA+E3_PREFIXO+E3_NUM+E3_PARCELA+E3_TIPO+E3_SEQ) == (xFilial("SE3")+SE1->(E1_XVENDCB+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO))

					If ( Empty(SE3->E3_DATA) ) // Nao esta pago

						If lAtuSldNat .and. cNatCom != NIL

							// Tratamento de outras moedas no controle de saldos do fluxo de caixa por natureza
							If SE3->(FieldPos("E3_MOEDA")) > 0 .AND. VAL(SE3->E3_MOEDA) > 1
								nValComis := NOROUND(XMOEDA(SE3->E3_COMIS,1,VAL(SE3->E3_MOEDA),SE3->E3_EMISSAO))
							Else
								nValComis := SE3->E3_COMIS
							EndIf

							//Atualizo o valor atual para o saldo da natureza
							AtuSldNat(cNatCom, SE3->E3_VENCTO, Iif(SE3->(FieldPos("E3_MOEDA")) > 0, SE3->E3_MOEDA, "01"), "2", "P", nValComis, SE3->E3_COMIS,"-",,FunName(),"SE3",SE3->(Recno()))

						EndIf

						FwLogMsg("INFO", , "REST", FunName(), "", "01", " >> FA070CAN - DELETANDO COMISSAO: "+SE3->(E3_FILIAL+E3_VEND+E3_CODCLI+E3_LOJA+E3_PREFIXO+E3_NUM+E3_PARCELA+E3_TIPO+E3_SEQ), 0, (nStart - Seconds()), {})

						If RecLock("SE3", .F.)

							SE3->(DbDelete())
							SE3->(MsUnlock())
						EndIf

					EndIf

					SE3->(DbSkip())
				EndDo

			EndIf

			FwLogMsg("INFO", , "REST", FunName(), "", "01",  ">> FA070CAN - LIMPANDO E1_XVENDCB DO TITULO: "+SE1->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO), 0, (nStart - Seconds()), {})

			If Reclock("SE1", .F.)

				SE1->E1_XVENDCB := ""
				SE1->E1_XFILVEN := ""

				SE1->(MsUnlock())
			EndIf

		EndIf

	EndIf

	RestArea(aAreaSE3)
	RestArea(aAreaSE1)
	RestArea(aArea)

Return