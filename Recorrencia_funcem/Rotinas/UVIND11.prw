#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "TBICONN.CH"
#INCLUDE "topconn.ch"

/*###########################################################################
#############################################################################
## Programa  | UVIND11 | Autor | Wellington Gon็alves  | Data | 04/03/2019 ##
##=========================================================================##
## Desc.     | Altera็ใo do Perfil de Pagamento do Cliente				   ##
##=========================================================================##
## Uso       | P๓stumos		                                               ##
#############################################################################
###########################################################################*/

User Function UVIND11()

Local aArea			:= GetArea()
Local aAreaU60		:= U60->(GetArea())
Local aAreaU64		:= U64->(GetArea())
Local lFuneraria	:= SuperGetMV("MV_XFUNE",,.F.)
Local lCemiterio	:= SuperGetMV("MV_XCEMI",,.F.)
Local lContinua		:= .T.
Local cFormaPgto	:= ""
Local cChavePerfil	:= ""
Local cStatusCtr	:= ""
Local cContrato		:= ""
Local cIntContrato	:= ""
Local lOK			:= .T.

if lFuneraria
	cFormaPgto 		:= UF2->UF2_FORPG
	cChavePerfil	:= UF2->UF2_CODIGO + UF2->UF2_CLIENT + UF2->UF2_LOJA
	cStatusCtr		:= UF2->UF2_STATUS
	cContrato		:= UF2->UF2_CODIGO
	cCodMod			:= "F"
elseif lCemiterio
	cChavePerfil	:= U00->U00_CODIGO + U00->U00_CLIENT + U00->U00_LOJA
	cStatusCtr		:= U00->U00_STATUS
	cContrato		:= U00->U00_CODIGO
	cCodMod			:= "C"

	if U00->(FieldPos("U00_TPCONT")) > 0
		cIntContrato := U00->U00_TPCONT
	endIf

	U60->(DbSetOrder(2)) // U60_FILIAL + U60_FORPG
	if U60->(DbSeek(xFilial("U60") + U00->U00_FORPG)) .Or.;
		U60->(DbSeek(xFilial("U60") + U00->U00_FPTAXA))

		cFormaPgto := Alltrim(U60->U60_FORPG)

	endif

endif

// contrato de integracao de empresas
if lContinua .And. cStatusCtr == "A" .And. cIntContrato == "2"
	MsgInfo("O Contrato de Integra็ใo de Empresas, opera็ใo nใo permitida.","Aten็ใo")
	lContinua := .F.
endIf

if lContinua

	if cStatusCtr <> "A" // Ativo
		Help(NIL, NIL, "Aten็ใo!", NIL, "O Contrato nใo estแ Ativo, opera็ใo nใo permitida!", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Selecione um Contrato Ativo!"})
	else

		// se a forma de pagamento estiver vinculada a um metodo de pagamento VINDI
		if !Empty(cFormaPgto)
							
			U60->(DbSetOrder(2)) // U60_FILIAL + U60_FORPG
			if U60->(DbSeek(xFilial("U60") + cFormaPgto))
							
				// se o metodo de pagamento estiver ativo
				if U60->U60_STATUS == "A"
							
					// posiciono no Perfil de Pagamento
					U64->(DbSetOrder(2)) // U64_FILIAL + U64_CONTRA + U64_CLIENT + U64_LOJA + U64_STATUS 
					if U64->(DbSeek(xFilial("U64") + cChavePerfil))
							
						// tela para preenchimento do perfil de pagamento
						FWMsgRun(,{|oSay| lOK := AltPerfil(cFormaPgto,cContrato,cCodMod)},'Aguarde...','Abrindo Perfil de Pagamento...')
						
					else
						Help(NIL, NIL, "Aten็ใo!", NIL, "Perfil de Pagamento nใo encontrado!", 1, 0, NIL, NIL, NIL, NIL, NIL)
					endif
									
				endif
							
			endif
							
		endif

	endif

endIf

RestArea(aAreaU60)
RestArea(aAreaU64)
RestArea(aArea)
	
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ IncPerfil บ Autor ณ Wellington Gon็alves บDataณ 25/01/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Abertura de cadastro MVC de Perfil de Pagamento			  นฑฑ
ฑฑบ			   															  นฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funerแria	                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function AltPerfil(cFormaPgto,cContrato,cCodMod)

	Local lRet 	:= .T.
	Local nAlt	:= 0

	nAlt := FWExecView('ALTERAR','UVIND07',4,,{|| .T. })

	if nAlt <> 0
		MsgInfo("A Altera็ใo do Perfil de Pagamento foi cancelada!","Aten็ใo!")
		lRet := .F.
	else

		// ้ necessแrio enviar o comando de exclusใo
		// e de inclusใo para vindi
		AtuFatVindi(cFormaPgto,cContrato,cCodMod)

	endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AtuFatVindi บAutorณ Wellington Gon็alves บDataณ 11/03/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Abertura de cadastro MVC de Perfil de Pagamento			  นฑฑ
ฑฑบ			   															  นฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funerแria	                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function AtuFatVindi(cFormaPgto,cContrato,cCodModulo)

	Local aArea 		:= GetArea()
	Local cQry			:= ""
	Local cPulaLinha	:= chr(13)+chr(10)
	Local oVindi		:= NIL
	Local cOrigem		:= "UVIND11"
	Local cOrigemDesc	:= "Alteracao de Perfil de Pagamento"

// verifico se existe este alias criado
	If Select("QRY") > 0
		QRY->(DbCloseArea())
	EndIf

	cQry := " SELECT "										   + cPulaLinha
	cQry += " SE1.E1_FILIAL AS FIL_TIT, "                      + cPulaLinha
	cQry += " SE1.E1_PREFIXO AS PREFIXO, "                     + cPulaLinha
	cQry += " SE1.E1_NUM AS NUM, "                             + cPulaLinha
	cQry += " SE1.E1_PARCELA AS PARCELA, "                     + cPulaLinha
	cQry += " SE1.E1_TIPO AS TIPO, "                           + cPulaLinha
	cQry += " SE1.E1_CLIENTE AS CLIENTE, "                     + cPulaLinha
	cQry += " SE1.E1_LOJA AS LOJA "                            + cPulaLinha
	cQry += " FROM "                                           + cPulaLinha
	cQry += " " + RetSqlName("SE1") + " SE1 "                  + cPulaLinha
	cQry += " WHERE "                                          + cPulaLinha
	cQry += " SE1.D_E_L_E_T_ <> '*' "                          + cPulaLinha
	cQry += " AND SE1.E1_FILIAL = '" + xFilial("SE1") + "' "   + cPulaLinha
	cQry += " AND SE1.E1_XFORPG = '" + cFormaPgto + "' "       + cPulaLinha
	cQry += " AND SE1.E1_SALDO > 0 "                           + cPulaLinha
	cQry += " AND SE1.E1_TIPO NOT IN ( "                       + cPulaLinha
	cQry += " 	'AB-','FB-','FC-','FU-','IR-', "               + cPulaLinha
	cQry += " 	'IN-','IS-','PI-','CF-','CS-', "               + cPulaLinha
	cQry += " 	'FE-','IV-','PR','PA','RA','NCC','NDC' "       + cPulaLinha
	cQry += " ) "                                              + cPulaLinha

	if cCodModulo == "C" // cemit้rio
		cQry += " AND SE1.E1_XCONTRA = '" + cContrato + "' "   + cPulaLinha
	elseif cCodModulo == "F" // funerแria
		cQry += " AND SE1.E1_XCTRFUN = '" + cContrato + "' "   + cPulaLinha
	endif

// crio o alias temporario
	TcQuery cQry New Alias "QRY" // Cria uma nova area com o resultado do query

// se existir contratos da funerแria vinculados ao cliente
	if QRY->(!Eof())

		// crio o objeto de integracao com a vindi
		oVindi := IntegraVindi():New()

		While QRY->(!Eof())

			// envia a alteracao do tํtulo atualizado
			oVindi:IncluiTabEnvio(cCodModulo,"3","A",1,QRY->FIL_TIT + QRY->PREFIXO + QRY->NUM + QRY->PARCELA + QRY->TIPO,/*aProc*/,cOrigem,cOrigemDesc)

			QRY->(DbSkip())

		Enddo

	endif

// verifico se existe este alias criado
	If Select("QRY") > 0
		QRY->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return()
