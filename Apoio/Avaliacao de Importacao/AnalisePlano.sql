-------------------------
-- CONTRATOS POR STATUS -
-------------------------

SELECT 
COUNT(*) TOTAL,
UF2_STATUS STATUS 
FROM UF2010  
WHERE D_E_L_E_T_ = ''
GROUP BY UF2_STATUS

--- TOTAL DE BENEFICIARIOS IMPORTADOS
SELECT 
COUNT(*) TOTAL
FROM UF4010 
WHERE D_E_L_E_T_ = ''
AND UF4_TIPO <> '3'

--- TOTAL DE BENEFICIARIOS HOMINMOS
SELECT COUNT(*) FROM (
SELECT 
COUNT(*) TOTAL, 
UF4_NOME NOME
FROM UF4010 
WHERE D_E_L_E_T_ = ''
AND UF4_TIPO <> '3'
GROUP BY UF4_NOME
HAVING COUNT(*) > 1 ) TOTAL_HOMONIMOS

--------------------------------
-- TITULOS IMPORTADOS          -
--------------------------------
SELECT COUNT(*) TOTAL
FROM SE1010
WHERE D_E_L_E_T_ = ''

--------------------------------
-- TITULOS EM ABERTO          -
--------------------------------
SELECT COUNT(*)  TOTAL,
SUM(E1_VALOR) VALOR
FROM SE1010
WHERE D_E_L_E_T_ = ''
AND E1_SALDO > 0 

--------------------------------
-- TITULOS BAIXADOS          -
--------------------------------
SELECT COUNT(*)  TOTAL,
SUM(E1_VALOR) VALOR
FROM SE1010
WHERE D_E_L_E_T_ = ''
AND E1_SALDO = 0 

--------------------------------
-- TITULOS VENCIDOS           -
--------------------------------
SELECT 
COUNT(*)  TOTAL,
SUM(E1_VALOR) VALOR
FROM SE1010
WHERE D_E_L_E_T_ = ''
AND E1_SALDO > 0 
AND E1_VENCREA < '20231127'


--------------------------------
-- TITULOS EM ABERTO POR ANO   -
--------------------------------
SELECT 
COUNT(*)  TOTAL,
SUM(E1_VALOR) VALOR
SUBSTRING(E1_VENCREA,1,4) ANO
FROM SE1010
WHERE D_E_L_E_T_ = ''
AND E1_SALDO > 0 
AND E1_VENCREA < '20231127'
GROUP BY SUBSTRING(E1_VENCREA,1,4)

SELECT 
E1_NUM,
E1_PORTADO BANCO,
E1_AGEDEP AGENCIA,
E1_CONTA CONTA, 
E1_NUMBCO NOSSO_NUMERO
FROM SE1010
WHERE D_E_L_E_T_ = ''
AND E1_NUMBCO <> ''
