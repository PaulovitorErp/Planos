#INCLUDE "TOTVS.CH"

User function TesteREST() 

Local aHeadOut		:= {}
Local oRestClient 	:= FWRest():New("https://app.vindi.com.br/api")
Local cJson			:= ""
Local aCabJson		:= {}  
Local aLinJson		:= {}
Local cKey			:= "ab9kQKu-HkPZ0VPE2q2zD4Dsfc27XNBQbnCA9kZ5kZU"
Local cAuth			:= "Basic " + Encode64(cKey)

oRestClient:setPath("/v1/customers")
oRestClient:nTimeOut := 15     

aadd(aHeadOut,"Content-Type:application/json")  
aadd(aHeadOut,"Authorization: " + cAuth)       

cJson := ' { '
cJson += '   "name": "Wellington - Primeiro Envio Protheus", '
cJson += '   "email": "wellington.go@hotmail.com", '
cJson += '   "code": "0101000001", '
cJson += '   "notes": "teste" '
cJson += ' } '

oRestClient:SetPostParams(cJson) 

If oRestClient:Post(aHeadOut)
   Alert(oRestClient:GetResult())
Else
   Alert(oRestClient:GetLastError())
Endif   

Return()