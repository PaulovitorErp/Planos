#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'
#INCLUDE "hbutton.ch"

/*�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������ͺ��
���Programa  � RUTIL005 � Autor � Wellington Gon�alves          � Data� 24/11/2016 ���
���������������������������������������������������������������������������������ͺ��
���Desc.     � Tela de agendamento de cobran�a									  ���
���������������������������������������������������������������������������������ͺ��
���Uso       � Vale do Cerrado		               			                      ���
���������������������������������������������������������������������������������ͺ��
�������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������*/

User Function RUTIL005()

Local aArea				:= GetArea()
Local aAreaACG			:= ACG->(GetArea())
Local oGroup1			:= NIL
Local oGroup2			:= NIL
Local oGroup3			:= NIL
Local oSayCliente		:= NIL
Local cCliente			:= ""
Local nQtdTot			:= 0
Local nVlTot			:= 0
Local nQtdSel			:= 0
Local nVlSel			:= 0
Local aButtons 			:= {}
Local aTitulos			:= {}
Local cAtendimento		:= M->ACF_CODIGO
Private oSayQtdTot		:= NIL
Private oSayVlTot		:= NIL
Private oSayQtdSel		:= NIL
Private oSayVlSel		:= NIL
Private oGridTitulos	:= NIL
Private nSayQtdTot		:= 0
Private nSayVlTot		:= 0
Private nSayQtdSel		:= 0
Private nSayVlSel		:= 0
Static oDlg				:= NIL

ACG->(DbSetOrder(1)) // ACG_FILIAL + ACG_CODIGO + ACG_PREFIX + ACG_TITULO + ACG_PARCEL + ACG_TIPO + ACG_FILORI
if ACG->(DbSeek(xFilial("ACG") + cAtendimento))

	While ACG->(!Eof()) .AND. ACG->ACG_FILIAL == xFilial("ACG") .AND. ACG->ACG_CODIGO == cAtendimento
	
		aadd(aTitulos,{ ACG->ACG_FILORI , ACG->ACG_PREFIX , ACG->ACG_TITULO , ACG->ACG_PARCEL , ACG->ACG_TIPO , ACG->ACG_DTREAL })
		
		ACG->(DbSkip())
	
	EndDo

	DEFINE MSDIALOG oDlg TITLE "Agendamento de Cobran�a" FROM 000, 000  TO 500, 800 COLORS 0, 16777215 PIXEL
	
	// Dados do cliente
	@ 035, 005 GROUP oGroup1 TO 060, 397 OF oDlg COLOR 0, 16777215 PIXEL
	@ 045, 015 SAY oSayCliente PROMPT "Cliente: 000001/01 - Totvs" SIZE 194, 007 OF oDlg COLORS 0, 16777215 PIXEL
	
	// Grid de t�tulos
	@ 065, 005 GROUP oGroup2 TO 215, 397 PROMPT "  T�tulos do Atendimento  " OF oDlg COLOR 0, 16777215 PIXEL
	MontaGrid()
	
	// Atualizo o grid
	RefreshGrid(aTitulos)
	
	// Totalizadores
	@ 220, 005 GROUP oGroup3 TO 245, 397 OF oDlg COLOR 0, 16777215 PIXEL
	@ 230, 010 SAY oSayQtdTot PROMPT "Qtd Total:  " + StrZero(nSayQtdTot,2) SIZE 058, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 230, 088 SAY oSayVlTot PROMPT  "Valor Total:  R$ " + AllTrim(Transform(nSayVlTot,"@E 999,999.99")) SIZE 077, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 230, 200 SAY oSayQtdSel PROMPT "Qtd Agendado:  " + StrZero(nSayQtdSel,2) SIZE 064, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 230, 305 SAY oSayVlSel PROMPT  "Valor Agendado:  R$ " + AllTrim(Transform(nSayVlSel,"@E 999,999.99")) SIZE 086, 007 OF oDlg COLORS 0, 16777215 PIXEL
	
	// Atualizo os totalizadores
	RefreshTotal(1,0)
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {||Confirmar()}, {||oDlg:End()},,aButtons)

endif

RestArea(aAreaACG)
RestArea(aArea)

Return()

/*�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������ͺ��
���Programa  � MontaGrid � Autor � Wellington Gon�alves        � Data� 24/11/2016 ���
���������������������������������������������������������������������������������ͺ��
���Desc.     � Fun��o que monta o grid de t�tulos								  ���
���������������������������������������������������������������������������������ͺ��
���Uso       � Vale do Cerrado		               			                      ���
���������������������������������������������������������������������������������ͺ��
�������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������*/
 
Static Function MontaGrid()
 
Local aHeaderEx 	:= {}
Local aColsEx 		:= {}
Local aFieldFill 	:= {}
Local aFields 		:= {"FILIAL","PREFIXO","NUMERO","PARCELA","TIPO","STATUS","VENCIMENTO","VALOR","DATA","HORA"}
Local aAlterFields 	:= {"DATA","HORA"}
Local nX			:= 1

// monto o cabe�alho do grid
For nX := 1 To Len(aFields)
	
	if aFields[nX] == "FILIAL"
		Aadd(aHeaderEx, {"Filial","FILIAL","",TamSX3("E1_FILIAL")[1],0,"","��������������","C","","","",""})
	elseif aFields[nX] == "PREFIXO"
		Aadd(aHeaderEx, {"Prefixo","PREFIXO","",TamSX3("E1_PREFIXO")[1],0,"","��������������","C","","","",""})
	elseif aFields[nX] == "NUMERO"
		Aadd(aHeaderEx, {"Numero","NUMERO","",TamSX3("E1_NUM")[1],0,"","��������������","C","","","",""})
	elseif aFields[nX] == "PARCELA"
		Aadd(aHeaderEx, {"Parcela","PARCELA","",TamSX3("E1_PARCELA")[1],0,"","��������������","C","","","",""})
	elseif aFields[nX] == "TIPO"
		Aadd(aHeaderEx, {"Tipo","TIPO","",TamSX3("E1_TIPO")[1],0,"","��������������","C","","","",""})
	elseif aFields[nX] == "STATUS"
		Aadd(aHeaderEx, {"Status","STATUS","",10,0,"","��������������","C","","","",""})
	elseif aFields[nX] == "VENCIMENTO"
		Aadd(aHeaderEx, {"Vencimento","VENCIMENTO","",8,0,"","��������������","D","","","",""})
	elseif aFields[nX] == "VALOR"
		Aadd(aHeaderEx, {"Valor","VALOR",PesqPict("SE1","E1_VALOR"),TamSX3("E1_VALOR")[1],TamSX3("E1_VALOR")[2],"","��������������","N","","","",""})
	elseif aFields[nX] == "DATA"
		Aadd(aHeaderEx, {"Data","DATA","",8,0,"U_RUTIL05A()","��������������","D","","","",""})
	elseif aFields[nX] == "HORA"
		Aadd(aHeaderEx, {"Hora","HORA","99:99",5,0,"U_RUTIL05B()","��������������","C","","","",""})
	endif
	
Next nX

// Crio uma linha em branco no grid
For nX := 1 To Len(aHeaderEx)
	
	if aHeaderEx[nX,8] == "C"
		Aadd(aFieldFill, "")
	elseif aHeaderEx[nX,8] == "N"
		Aadd(aFieldFill, 0)
	elseif aHeaderEx[nX,8] == "D"
		Aadd(aFieldFill, CTOD("  /  /    "))
	elseif aHeaderEx[nX,8] == "L"
		Aadd(aFieldFill, .F.)
	endif
	
Next nX

Aadd(aFieldFill, .F.)
Aadd(aColsEx, aFieldFill)

oGridTitulos := MsNewGetDados():New( 075, 010, 210, 392,GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999,"AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)

Return()

/*�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������ͺ��
���Programa  � RefreshGrid � Autor � Wellington Gon�alves      � Data� 24/11/2016 ���
���������������������������������������������������������������������������������ͺ��
���Desc.     � Fun��o que atualiza o grid										  ���
���������������������������������������������������������������������������������ͺ��
���Uso       � Vale do Cerrado		               			                      ���
���������������������������������������������������������������������������������ͺ��
�������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������*/

Static Function RefreshGrid(aTitulos)

Local aField 	:= {}
Local aItens	:= {}
Local nX		:= 1

// limpo o Grid
oGridTitulos:aCols := {}

For nX := 1 To Len(aTitulos)

	aField := {}

	// {"FILIAL","PREFIXO","NUMERO","PARCELA","TIPO","STATUS","VENCIMENTO","VALOR","DATA","HORA"}
	SE1->(DbSetOrder(1)) // E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
	if SE1->(DbSeek(aTitulos[nX,1] + aTitulos[nX,2] + aTitulos[nX,3] + aTitulos[nX,4] + aTitulos[nX,5]))
	
		aadd(aField , SE1->E1_FILIAL)
		aadd(aField , SE1->E1_PREFIXO)
		aadd(aField , SE1->E1_NUM)
		aadd(aField , SE1->E1_PARCELA)
		aadd(aField , SE1->E1_TIPO)
		aadd(aField , iif(SE1->E1_VENCREA <= dDataBase , "N�o vencido" , "Vencido"))
		aadd(aField , SE1->E1_VENCREA)
		aadd(aField , SE1->E1_VALOR)
		aadd(aField , SE1->E1_XDTCOB)
		aadd(aField , SE1->E1_XHRCOB)
		aadd(aField , .F.)
		
		aadd(aItens , aField)
		
	endif

Next nX

oGridTitulos:aCols := aClone(aItens)

oGridTitulos:oBrowse:Refresh()

Return()

/*�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������ͺ��
���Programa  � RefreshTotal � Autor � Wellington Gon�alves     � Data� 02/01/2017 ���
���������������������������������������������������������������������������������ͺ��
���Desc.     � Fun��o que atualiza os totalizadores 							  ���
���������������������������������������������������������������������������������ͺ��
���Uso       � Vale do Cerrado		               			                      ���
���������������������������������������������������������������������������������ͺ��
�������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������*/

Static Function RefreshTotal(nOrigem,nLine)

Local nPosData 	:= aScan(oGridTitulos:aHeader,{|x| AllTrim(x[2]) == "DATA"})
Local nPosHora 	:= aScan(oGridTitulos:aHeader,{|x| AllTrim(x[2]) == "HORA"})
Local nPosValor	:= aScan(oGridTitulos:aHeader,{|x| AllTrim(x[2]) == "VALOR"})
Local dDtAgenda	:= CTOD("  /  /    ")
Local cHrAgenda	:= ""
Local nX 		:= 1

// zero os totalizadores
nSayQtdTot 	:= 0
nSayVlTot	:= 0
nSayQtdSel	:= 0
nSayVlSel	:= 0

// percorro todos os itens do grid
For nX := 1 To Len(oGridTitulos:aCols)

	if nOrigem == 1 .OR. nLine <> nX
		dDtAgenda 	:= oGridTitulos:aCols[nX,nPosData] 
		cHrAgenda	:= oGridTitulos:aCols[nX,nPosHora]
	elseif nOrigem == 2
		dDtAgenda 	:= M->DATA 
		cHrAgenda	:= oGridTitulos:aCols[nX,nPosHora]
	elseif nOrigem == 3
		dDtAgenda 	:= oGridTitulos:aCols[nX,nPosData] 
		cHrAgenda	:= M->HORA
	endif

	if !Empty(dDtAgenda) .AND. !Empty(SubStr(cHrAgenda,1,2)) 
		nSayQtdSel++
		nSayVlSel += oGridTitulos:aCols[nX,nPosValor]	
	endif

	nSayQtdTot++
	nSayVlTot += oGridTitulos:aCols[nX,nPosValor]

Next nX

// atualizo o objeto dos totalizadores
oSayQtdTot:Refresh()
oSayVlTot:Refresh()
oSayQtdSel:Refresh()
oSayVlSel:Refresh()

Return()

/*�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������ͺ��
���Programa  � RUTIL05A � Autor � Wellington Gon�alves    	   � Data� 02/01/2017 ���
���������������������������������������������������������������������������������ͺ��
���Desc.     � Fun��o chamada na valida��o do campo DATA						  ���
���������������������������������������������������������������������������������ͺ��
���Uso       � Vale do Cerrado		               			                      ���
���������������������������������������������������������������������������������ͺ��
�������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������*/

User Function RUTIL05A()

Local lRet := .T.

if !Empty(M->DATA) .AND. M->DATA < dDataBase
	Alert("A data informada n�o pode ser menor que a data do sistema!")
	lRet := .F.
else
	// Atualizo os totalizadores
	RefreshTotal(2,oGridTitulos:nAt)
endif

Return(lRet)

/*�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������ͺ��
���Programa  � RUTIL05B � Autor � Wellington Gon�alves    	   � Data� 02/01/2017 ���
���������������������������������������������������������������������������������ͺ��
���Desc.     � Fun��o chamada na valida��o do campo HORA						  ���
���������������������������������������������������������������������������������ͺ��
���Uso       � Vale do Cerrado		               			                      ���
���������������������������������������������������������������������������������ͺ��
�������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������*/

User Function RUTIL05B()

Local lRet 		:= .T.
Local cTime		:= M->HORA

// se a hora estiver preechida
if !Empty(cTime) .AND. ( !Empty(SubStr(cTime,1,2)) .OR. !Empty(SubStr(cTime,4,2)) )    

	// valido primeiramente o tamanho do campo
	// dever� ser informado no formato 99:99
	if Len(AllTrim(SubStr(cTime,1,2))) < 2 .OR. Len(AllTrim(SubStr(cTime,4,2))) < 2       
		Alert("Informe todos os d�gitos do campo Hora!")
		lRet := .F.
	else
	
		// valido o conte�do da hora e minuto, no formato 24 horas
		if ( Val(SubStr(cTime,1,2)) < 0 .OR. Val(SubStr(cTime,1,2)) > 23 ) .OR. ( Val(SubStr(cTime,4,2)) < 0 .OR. Val(SubStr(cTime,4,2)) > 59 )   
			Alert("A hora informada � inv�lida!")
			lRet := .F.
		endif 
		
	endif 

endif

if lRet
	// Atualizo os totalizadores
	RefreshTotal(3,oGridTitulos:nAt)
endif

Return(lRet)

/*�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������ͺ��
���Programa  � Confirmar � Autor � Wellington Gon�alves    	   � Data� 02/01/2017 ���
���������������������������������������������������������������������������������ͺ��
���Desc.     � Fun��o chamada na confirma��o da tela							  ���
���������������������������������������������������������������������������������ͺ��
���Uso       � Vale do Cerrado		               			                      ���
���������������������������������������������������������������������������������ͺ��
�������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������*/

Static Function Confirmar()

Local aArea		:= GetArea()
Local aAreaSE1	:= SE1->(GetArea())
Local nPosData 	:= aScan(oGridTitulos:aHeader,{|x| AllTrim(x[2]) == "DATA"})
Local nPosHora 	:= aScan(oGridTitulos:aHeader,{|x| AllTrim(x[2]) == "HORA"})
Local nPosValor	:= aScan(oGridTitulos:aHeader,{|x| AllTrim(x[2]) == "VALOR"})
Local nPosFil	:= aScan(oGridTitulos:aHeader,{|x| AllTrim(x[2]) == "FILIAL"})
Local nPosPref	:= aScan(oGridTitulos:aHeader,{|x| AllTrim(x[2]) == "PREFIXO"})
Local nPosNum	:= aScan(oGridTitulos:aHeader,{|x| AllTrim(x[2]) == "NUMERO"})
Local nPosPar	:= aScan(oGridTitulos:aHeader,{|x| AllTrim(x[2]) == "PARCELA"})
Local nPosTipo	:= aScan(oGridTitulos:aHeader,{|x| AllTrim(x[2]) == "TIPO"})
Local nX		:= 1
Local lOK		:= .T.

if MsgYesNo("Deseja confirmar o agendamento de cobran�a?")

	// Inicio o controle de transa��o
	BeginTran()
	
	// percorro todos os itens do grid
	For nX := 1 To Len(oGridTitulos:aCols)
	
		SE1->(DbSetOrder(1)) // E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
		if SE1->(DbSeek(oGridTitulos:aCols[nX,nPosFil] + oGridTitulos:aCols[nX,nPosPref] + oGridTitulos:aCols[nX,nPosNum] + oGridTitulos:aCols[nX,nPosPar] + oGridTitulos:aCols[nX,nPosTipo]))
		
			if RecLock("SE1",.F.)
			
				SE1->E1_XDTCOB	:= oGridTitulos:aCols[nX,nPosData] 
				SE1->E1_XHRCOB	:= oGridTitulos:aCols[nX,nPosHora] 
				SE1->(MsUnLock())
				
			else
				lOK := .F.
				Exit
			endif
		
		endif
	
	Next nX
	
	if lOK
	
		// finalizo o controle de transa��o
		EndTran()
		
		// fecho a tela
		oDlg:End()
		MsgInfo("Agendamento realizado com sucesso!")
		
	else				
		// aborto a transa��o
		DisarmTransaction()
		Alert("Ocorreu um problema na grava��o do agendamento!")
	endif

endif

RestArea(aAreaSE1)
RestArea(aArea)

Return()