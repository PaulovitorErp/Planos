#include 'protheus.ch'

/*/{Protheus.doc} RUTILE02
Verifica o modo edição dos campos - rotina Gerador de Termos
@author TOTVS
@since 04/04/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/

/*****************************/
User Function RUTILE02(cCampo)
/*****************************/
	
Local lRet := .T.

Do Case

	Case cCampo == "UG6_CONTEU" //Conteúdo

		If FWFldGet("UG6_ACAO") == "I" .Or. FWFldGet("UG6_ACAO") == "Q" .Or. FWFldGet("UG6_ACAO") == "S" .Or.;
		 	FWFldGet("UG6_ACAO") == "T" .Or. FWFldGet("UG6_ACAO") == "L" //Imagem Ou Quebra de linha Ou Separador Ou Tabela Ou Lista
			lRet := .F.
		Endif
	
	Case cCampo == "UG6_LOCAL" //Local
		
		If FWFldGet("UG6_ACAO") <> "I" //Imagem
			lRet := .F.
		Endif
		
	Case cCampo == "UG6_ALTURA" //Altura
		
		If FWFldGet("UG6_ACAO") <> "I" //Imagem
			lRet := .F.
		Endif

	Case cCampo == "UG6_LARGUR" //Largura
		
		If FWFldGet("UG6_ACAO") <> "I" .And. FWFldGet("UG6_ACAO") <> "S" //Imagem E Separador
			lRet := .F.
		Endif

	Case cCampo == "UG6_FONTE" //Fonte
		
		If FWFldGet("UG6_ACAO") == "I" .Or. FWFldGet("UG6_ACAO") == "Q" .Or. FWFldGet("UG6_ACAO") == "S" //Imagem Ou Quebra de linha Ou Separador
			lRet := .F.
		Endif

	Case cCampo == "UG6_TAMANH" //Tamanho Fonte
		
		If FWFldGet("UG6_ACAO") == "I" .Or. FWFldGet("UG6_ACAO") == "Q" .Or. FWFldGet("UG6_ACAO") == "S" .Or.  FWFldGet("UG6_ACAO") == "U" //Imagem Ou Quebra de linha Ou Separador Ou Titulo
			lRet := .F.
		Endif
		
	Case cCampo == "UG6_TAMCAB" //Tamanho Cabeçalho
		
		If FWFldGet("UG6_ACAO") <> "U" //Titulo
			lRet := .F.
		Endif

	Case cCampo == "UG6_ALINHA" //Alinhamento
		
		If FWFldGet("UG6_ACAO") == "Q" //Quebra
			lRet := .F.
		Endif

	Case cCampo == "UG6_ESTILO" //Estilo
		
		If FWFldGet("UG6_ACAO") == "I" .Or. FWFldGet("UG6_ACAO") == "Q" .Or. FWFldGet("UG6_ACAO") == "S" //Imagem Ou Quebra de linha Ou Separador
			lRet := .F.
		Endif

	Case cCampo == "UG6_TIPLIS" //Tipo Lista
		
		If FWFldGet("UG6_ACAO") <> "L" //Lista
			lRet := .F.
		Endif
EndCase

Return lRet