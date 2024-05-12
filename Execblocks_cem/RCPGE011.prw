#include "protheus.ch" 

/*/{Protheus.doc} RCPGE011
Preenchimento dinâmico das opções do campo U00_DIAVEN
@author TOTVS
@since 18/11/2017
@version P12
@param Nao recebe parametros
@return nulo
/*/

/***********************/
User function RCPGE011()
/***********************/

Local cRet 			:= ""
Local cTpDiaVenc	:= SuperGetMv("MV_XTPDIAV",.F.,"1") 

If cTpDiaVenc == "1" //Intervalo de 05 dias
	cRet := "5;10;15;20;25;30"
Else
	cRet := "1;2;3;4;5;6;7;8;9;10;11;12;13;14;15;16;17;18;19;20;21;22;23;24;25;26;27;28;29;30;31"
Endif

Return cRet