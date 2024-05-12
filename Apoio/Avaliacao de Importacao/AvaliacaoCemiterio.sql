-------------------------
-- CONTRATOS POR STATUS -
-------------------------

SELECT 
COUNT(*) TOTAL,
U00_STATUS STATUS 
FROM U00010  
WHERE D_E_L_E_T_ = ''
GROUP BY U00_STATUS

--------------------------------
-- CONTRATOS SEM ENDEREÇAMENTO -
--------------------------------
SELECT 
COUNT(*) TOTAL FROM U00010 U00
WHERE U00.D_E_L_E_T_ = ''
AND NOT EXISTS ( SELECT U04_CODIGO FROM U04010 U04 WHERE U04.D_E_L_E_T_ = '' AND U04.U04_CODIGO = U00.U00_CODIGO )

--------------------------------
-- CLIENTES SEM CONTRATO      -
--------------------------------
SELECT 
COUNT(*) TOTAL 
FROM SA1010 SA1
WHERE SA1.D_E_L_E_T_ = ''
AND NOT EXISTS ( SELECT U00_CODIGO FROM U00010 U00 WHERE U00.D_E_L_E_T_ = '' AND U00.U00_CLIENT = SA1.A1_COD )

--------------------------------
-- CLIENTES SEM CONTRATO      -
--------------------------------
SELECT 
COUNT(*) TOTAL,
SUBSTRING(U00_DTATIV,1,4) 
FROM U00010 U00
WHERE U00.D_E_L_E_T_ = ''
AND NOT EXISTS ( SELECT E1_NUM FROM SE1010 SE1 WHERE SE1.D_E_L_E_T_ = '' AND U00.U00_CODIGO = SE1.E1_XCONTRA )
GROUP BY SUBSTRING(U00_DTATIV,1,6) 
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
GROU BY SUBSTR(E1_VENCREA,1,4)

--------------------------------
-- TOTAL DE JAZIGOS CADASTRADOS -
--------------------------------
SELECT COUNT(*) FROM U10010 
WHERE D_E_L_E_T_ = ''

--------------------------------
-- TOTAL DE ENDEREÇADOS        -
--------------------------------

SELECT COUNT(*) TOTAL FROM U04010 
WHERE D_E_L_E_T_ = ''

-----------------------------------------
-- TOTAL DE JAZIGOS ENDEREÇADOS        -
-----------------------------------------

SELECT COUNT(*) TOTAL_JAZIGOS FROM 
(
    SELECT COUNT(*) TOTAL, U04_QUADRA, U04_MODULO, U04_JAZIGO  FROM U04010 
    WHERE D_E_L_E_T_ = ''
    GROUP BY U04_QUADRA, U04_MODULO, U04_JAZIGO
) ENDERECO


-----------------------------------------
-- TOTAL DE ENDEREÇADOS POR QUADRA      -
-----------------------------------------
SELECT COUNT(*) TOTAL, U04_QUADRA  FROM U04010 
WHERE D_E_L_E_T_ = ''
GROUP BY U04_QUADRA

-----------------------------------------
-- TOP 10 JAZIGOS UTILIZADOS            -
-----------------------------------------




