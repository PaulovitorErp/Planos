#include "protheus.ch" 

/*/{Protheus.doc} FTMSREL
Para que se possa utilizar o banco de conhecimentos utilizando uma tabela de usuário ( Ex. SZ1 ) torna-se necessário informar ao sistema qual a 
chave primaria de relacionamento. Por exemplo, a chave primaria de relacionamento do cadastro de clientes  FILIAL+CODIGO+LOJA
@author TOTVS
@since 08/03/2016
@version P12
@param Nao recebe parametros
@return nulo
/*/

/**********************/
User Function FTMSREL()
/**********************/

Local aEntidade 	:= {}

Local lFuneraria	:= SuperGetMV("MV_XFUNE",,.F.)
Local lCemiterio	:= SuperGetMV("MV_XCEMI",,.F.)

Private aRotina

If lCemiterio .Or. lFuneraria 

	AAdd(aEntidade,{"U00",{"U00_CODIGO"},{||U00->U00_CODIGO}}) //Contrato - Cemitério	
	AAdd(aEntidade,{"U05",{"U05_CODIGO"},{||U05->U05_CODIGO}}) //Tipos de Plano	
	AAdd(aEntidade,{"UF2",{"UF2_CODIGO"},{||UF2->UF2_CODIGO}}) //Contrato - Funerária
	AAdd(aEntidade,{"UG5",{"UG5_CODIGO"},{||UG5->UG5_CODIGO}}) //Gerador de Termos	
	AAdd(aEntidade,{"UF0",{"UF0_CODIGO"},{||UF0->UF0_CODIGO}}) //Tipos de Plano Funerarios
	
Endif

Return (aEntidade)