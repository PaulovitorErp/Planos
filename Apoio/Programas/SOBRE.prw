#Include "PROTHEUS.CH"

/*/{Protheus.doc} SOBREE
Notas de versao do Ecossistema Virtus
@author Leandro Rodrigues
@since 12/08/2019
@version P12
@param nulo
@return nulo
/*/

User Function SOBRE()

Local oFechar
Local oGroup1
Local oVirtus
Local oVersao
Local oTHButton
Local oFont    := TFont():New('Courier new',,12,.T.) 
Local oFont15N := TFont():New('Arial',,15,,.T.,,,,.T.,.F.) 

Static oDlg

DEFINE DIALOG oDlg TITLE "Sobre" FROM 000, 000  TO 350, 300 PIXEL   
 
 // Cria uma instância da classe TFont
 oFont := TFont():New('Courier new',,18,.T.)
 
    @ 010, 060 BITMAP oBitmap1 SIZE 052, 037 OF oDlg FILENAME "virtus.png" NOBORDER PIXEL  
    @ 045, 042 SAY oVirtus PROMPT "ECOSSISTEMA VIRTUS" FONT oFont15N SIZE 075, 010 OF oDlg COLORS 0, 16777215 PIXEL

    oTHVersao := THButton():New(050,045,"Versão : 2.0.3",oDlg,{|| OpenLink("https://tbc.atlassian.net/wiki/spaces/VP/overview") },60,20,oFont,"Clique aqui")

    oTHPortal := THButton():New(090,01,"Acesse o portal do conhecimento",oDlg,{|| OpenLink("https://tbc.atlassian.net/wiki/spaces/VP/pages/12779537/Virtus+-+Gest+o+de+Planos+Funer+rios") },150,20,,"Clique aqui")
 
     @ 125, 041 SAY oCodVer PROMPT "Conheca nossos parceiros" SIZE 150, 007 OF oDlg COLORS 0, 16777215 PIXEL


    //Parceiros
    @ 135, 042 BITMAP oBitmap1 SIZE 052, 037 OF oDlg FILENAME "totvs_template.png" NOBORDER PIXEL  
    @ 137, 080 BITMAP oBitmap1 SIZE 052, 037 OF oDlg FILENAME "vindi.png" NOBORDER PIXEL 

    @ 155, 040 SAY oCodVer PROMPT "Copyrigth © 2019 Virtus app" SIZE 150, 007 OF oDlg COLORS 0, 16777215 PIXEL

 ACTIVATE DIALOG oDlg CENTERED

Return

/*/{Protheus.doc} SOBREE
Abre navegador com o link da pagina
@author Leandro Rodrigues
@since 12/08/2019
@version P12
@param nulo
@return nulo
/*/

Static function OpenLink(cLink)


ShellExecute( "Open", "%PROGRAMFILES%\Internet Explorer\iexplore.exe", cLink, "C:\", 1 )

Return 