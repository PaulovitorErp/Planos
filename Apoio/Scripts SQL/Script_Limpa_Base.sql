--//SCRIPT DE LIMPEZA DE BASE STOCK//--

--//Limpa ultimas compras;
UPDATE SA1010 SET A1_NROCOM = 0, A1_MSALDO = 0, A1_PRICOM = ' ', A1_ULTCOM = ' ';
UPDATE SA2010 SET A2_NROCOM = 0, A2_MSALDO = 0, A2_PRICOM = ' ', A2_ULTCOM = ' ',A2_MATR = 0, A2_SALDUP = 0;
UPDATE SA6010 SET A6_SALATU = 0;

--//Limpa OMS;
if object_id('DAI010') is not null begin -- Itens da Carga                
	TRUNCATE  FROM DAI010; 
end 

if object_id('DAK010') is not null begin -- Carga
	TRUNCATE  FROM DAK010;
end 

if object_id('SC5010') is not null begin -- Cabecalho Pedido Venda
	TRUNCATE  FROM SC5010;
end

if object_id('SC6010') is not null begin -- Itens Pedido de Venda
	TRUNCATE  FROM SC6010;
end 

if object_id('SC9010') is not null begin -- Pedidos Liberados             
	TRUNCATE  FROM SC9010;
end 

if object_id('SF2010') is not null begin -- Cabe�alho das NF de Sa�da     
	TRUNCATE  FROM SF2010;  
end 

if object_id('SD2010') is not null begin -- Itens de Venda da NF          
	TRUNCATE  FROM SD2010;  
end 
  
--//Limpa Estoque;
if object_id('SD1010') is not null begin --Itens das NF de Entrada       
	TRUNCATE  FROM SD1010;   
end 

if object_id('SD2010') is not null begin -- Itens de Venda da NF          
	TRUNCATE  FROM SD2010;    
end

if object_id('SD3010') is not null begin -- Movimenta��es Internas        
	TRUNCATE  FROM SD3010;    
end

if object_id('SD5010') is not null begin -- Requisi��es por Lote          
	TRUNCATE  FROM SD5010;     
end

if object_id('SD6010') is not null begin -- Itens do Contrato             
	TRUNCATE  FROM SD6010;      
end

if object_id('SD5010') is not null begin -- Requisi��es por Lote          
	TRUNCATE  FROM SD7010;       
end

if object_id('SDA010') is not null begin -- Saldos a Distribuir           
	TRUNCATE  FROM SDA010;        
end

if object_id('SDB010') is not null begin -- Movimentos de Distribui��o    
	TRUNCATE  FROM SDB010;         
end

if object_id('SDC010') is not null begin -- Composi��o do Empenho         
	TRUNCATE  FROM SDC010; 
end

if object_id('SDD010') is not null begin -- Bloqueio de Lotes             
	TRUNCATE  FROM SDD010;  
end

if object_id('SCP010') is not null begin -- Solicita��es ao Armaz�m       
	TRUNCATE  FROM SCP010;  
end

if object_id('SCQ010') is not null begin -- Pr�-Requisi��es               
	TRUNCATE  FROM SCQ010;  
end

if object_id('SB2010') is not null begin -- Saldos F�sico e Financeiro    
	TRUNCATE  FROM SB2010;
end

if object_id('SB3010') is not null begin -- Demandas                      
	TRUNCATE  FROM SB3010;
end

if object_id('SB6010') is not null begin -- Saldo em Poder de Terceiros   
	TRUNCATE  FROM SB6010;
end

if object_id('SB7010') is not null begin -- Lan�amentos do Invent�rio     
	TRUNCATE  FROM SB7010;
end

if object_id('SB8010') is not null begin -- Saldos por Lote               
	TRUNCATE  FROM SB8010;
end

if object_id('SB9010') is not null begin -- Saldos Iniciais               
	TRUNCATE  FROM SB9010;
end

if object_id('SBF010') is not null begin -- Saldos por Endere�o           
	TRUNCATE  FROM SBF010;
end

if object_id('SF1010') is not null begin -- Cabe�alho das NF de Entrada   
	TRUNCATE  FROM SF1010;
end

if object_id('SBK010') is not null begin -- Saldos Iniciais por Endere�o  
	TRUNCATE  FROM SBK010;
end

if object_id('SBJ010') is not null begin -- Saldos Iniciais por Lote      
	TRUNCATE  FROM SBJ010;
end

if object_id('SDS010') is not null begin -- Cabe�alho importa��o XML NF-e 
	TRUNCATE  FROM SDS010;
end

if object_id('SDT010') is not null begin -- Itens importa��o XML NF-e     
	TRUNCATE  FROM SDT010;
end


--//Limpa Call Center;
if object_id('SK1010') is not null begin -- Refer�ncia do Contas a Receber
	TRUNCATE  FROM SK1010;
end

if object_id('ACG010') is not null begin -- Itens de Telecobran�a         
	TRUNCATE  FROM ACG010;
end

if object_id('ACF010') is not null begin -- Telecobran�a                  
	TRUNCATE  FROM ACF010;
end

if object_id('SUB010') is not null begin --Itens do Or�amento Televendas 
	TRUNCATE  FROM SUB010;
end

if object_id('SUA010') is not null begin --Or�amento Televendas          
	TRUNCATE  FROM SUA010;
end

if object_id('SUC010') is not null begin --Cabe�alho do Telemarketing    
	TRUNCATE  FROM SUC010;
end

if object_id('SUD010') is not null begin --Itens do Telemarketing        
	TRUNCATE  FROM SUD010;
end

if object_id('SU8010') is not null begin --Hist�rico de Marketing        
	TRUNCATE  FROM SU8010;
end

--//Limpa Ativo Fixo;
if object_id('SN4010') is not null begin -- Movimenta��es do Ativo Fixo   
	TRUNCATE  FROM SN4010; 
end

if object_id('SN5010') is not null begin -- Arquivos de Saldos            
	TRUNCATE  FROM SN5010; 
end

if object_id('SN6010') is not null begin --Saldos por Conta e Item       
	TRUNCATE  FROM SN6010; 
end

if object_id('SNA010') is not null begin --Saldos Conta x Item x Cl Valor
	TRUNCATE  FROM SNA010;  
end

if object_id('SNC010') is not null begin --Saldos Conta x Centro Custo   
	TRUNCATE  FROM SNC010;   
end

if object_id('SN8010') is not null begin --Invent�rio                    
	TRUNCATE  FROM SN8010;   
end

if object_id('SNP010') is not null begin --Cadastro de Bens em Terceiros                     
	TRUNCATE  FROM SNP010;   
end

--//Limpa Fiscal; 
if object_id('SF3010') is not null begin --Livros Fiscais                
	TRUNCATE  FROM SF3010;   
end

if object_id('SFT010') is not null begin --Livro Fiscal por Item de NF   
	TRUNCATE  FROM SFT010;   
end

if object_id('SF6010') is not null begin --Guias de Recolhimento         
	TRUNCATE  FROM SF6010;   
end

if object_id('SF8010') is not null begin --Amarra��o NF Orig x NF Imp/Fre
	TRUNCATE  FROM SF8010;    
end

if object_id('SFA010') is not null begin --Estorno Mensal CIAP           
	TRUNCATE  FROM SFA010;     
end

if object_id('CD2010') is not null begin --Livro digital de Impostos-SPED
	TRUNCATE  FROM CD2010;      
end

--//Limpa Contabilidade;
if object_id('CT2010') is not null begin --Lan�amentos Cont�beis         
	TRUNCATE  FROM CT2010;      
end

if object_id('CT3010') is not null begin --Saldos Centro de Custo        
	TRUNCATE  FROM CT3010;       
end

if object_id('CT4010') is not null begin --Saldos Item Cont�bil          
	TRUNCATE  FROM CT4010;        
end

if object_id('CT6010') is not null begin --Totais de Lotes               
	TRUNCATE  FROM CT6010;
end

if object_id('CT7010') is not null begin --Saldos Planos de Contas       
	TRUNCATE  FROM CT7010;
end

if object_id('CTC010') is not null begin --Saldos do Documento           
	TRUNCATE  FROM CTC010; 
end

if object_id('CTI010') is not null begin -- Saldos da Classe de Valores   
	TRUNCATE  FROM CTI010;
end

if object_id('CTK010') is not null begin -- Arquivo de Contra-Prova       
	TRUNCATE  FROM CTK010; 
end

if object_id('CTU010') is not null begin -- Saldos Totais por Entidade    
	TRUNCATE  FROM CTU010;  
end

if object_id('CTV010') is not null begin --Saldos Item x Centro de Custo 
	TRUNCATE  FROM CTV010;   
end

if object_id('CTW010') is not null begin -- Saldos Cl Valor x Centro Custo
	TRUNCATE  FROM CTW010;   
end

if object_id('CTX010') is not null begin--Saldos Cl Valor x Item        
	TRUNCATE  FROM CTX010; 
end

if object_id('CTY010') is not null begin --Saldos CCusto x Item x ClValor
	TRUNCATE  FROM CTY010;  
end

if object_id('CV3010') is not null begin --Rastreamento Lan�amento       
	TRUNCATE  FROM CV3010;   
end

if object_id('CV8010') is not null begin -- Log de Processamento          
	TRUNCATE  FROM CV8010;    
end

--//Limpa Financeiro;
if object_id('SE1010') is not null begin -- Contas a Receber              
	TRUNCATE  FROM SE1010;    
end

if object_id('SE2010') is not null begin -- Contas a Pagar
	TRUNCATE  FROM SE2010;     
end

if object_id('SE3010') is not null begin --Comiss�es de Vendas           
	TRUNCATE  FROM SE3010;     
end

if object_id('SE5010') is not null begin --Movimenta��o Bancaria         
	TRUNCATE  FROM SE5010;      
end

if object_id('SE8010') is not null begin -- Saldos Banc�rios              
	TRUNCATE  FROM SE8010;       
end

if object_id('SE9010') is not null begin --Contratos Banc�rios           
	TRUNCATE  FROM SE9010;        
end

if object_id('SEA010') is not null begin --T�tulos Enviados ao Banco
	TRUNCATE  FROM SEA010;    				          
end

if object_id('SEF010') is not null begin -- Cheques                       
	TRUNCATE  FROM SEF010;          
end

if object_id('SEG010') is not null begin --Controle de Aplica��es        
	TRUNCATE  FROM SEG010;           
end

if object_id('SEH010') is not null begin -- Controle Aplica��o/Emprestimo 
	TRUNCATE  FROM SEH010;            
end


if object_id('SEU010') is not null begin -- Movimentos do Caixinha        
	TRUNCATE  FROM SEU010;              
end

if object_id('SEV010') is not null begin -- M�ltiplas Naturezas por T�tulo
	TRUNCATE  FROM SEV010;               
end

if object_id('SEZ010') is not null begin -- Distrib de Naturezas em CC    
	TRUNCATE  FROM SEZ010;                
end

if object_id('FIW010') is not null begin --SALDO MENSAL POR NATUREZA     
	TRUNCATE  FROM FIW010;                
end

if object_id('FIV010') is not null begin --MOVIMENTOS DIARIOS P/NATUREZA 
	TRUNCATE  FROM FIV010;                
end

if object_id('FK1010') is not null begin -- Baixas a Receber              
	TRUNCATE  FROM FK1010;                
end

if object_id('FK2010') is not null begin -- Baixas a Pagar                
	TRUNCATE  FROM FK2010;                
end

if object_id('FK3010') is not null begin -- Impostos Calculados           
	TRUNCATE  FROM FK3010;                
end

if object_id('FK4010') is not null begin -- Impostos Retidos              
	TRUNCATE  FROM FK4010;                
end

if object_id('FK5010') is not null begin -- Movimentos Banc�rios          
	TRUNCATE  FROM FK5010;                
end

if object_id('FK6010') is not null begin -- Valores Acess�rios            
	TRUNCATE  FROM FK6010;                
end

if object_id('FK7010') is not null begin -- Tabela Auxiliar               
	TRUNCATE  FROM FK7010;                
end

if object_id('FK8010') is not null begin -- Dados cont�beis               
	TRUNCATE  FROM FK8010;                
end

if object_id('FK9010') is not null begin -- Auxiliar de integra��o        
	TRUNCATE  FROM FK9010;                
end

if object_id('FKA010') is not null begin -- Rastreio de Movimentos        
	TRUNCATE  FROM FKA010;                
end

if object_id('FKB010') is not null begin -- Tipos de Movimentos           
	TRUNCATE  FROM FKB010;                
end

--//Limpa Compras;

if object_id('SC1010') is not null begin -- Solicita��es de Compra        
	TRUNCATE  FROM SC1010;                
end

if object_id('SC3010') is not null begin -- Contrato de Parceria          
	TRUNCATE  FROM SC3010;                
end

if object_id('SC7010') is not null begin -- Ped.Compra / Aut.Entrega      
	TRUNCATE  FROM SC7010;                
end

if object_id('SC8010') is not null begin -- Cota��es                      
	TRUNCATE  FROM SC8010;                
end

if object_id('SCE010') is not null begin -- Encerramento de Cota��es      
	TRUNCATE  FROM SCE010;                
end

if object_id('SCS010') is not null begin -- Saldos dos Aprovadores        
	TRUNCATE  FROM SCS010;                
end


--//Limpa Cemiterio
if object_id('U00010') is not null begin -- Contrato Cemiterio
	TRUNCATE  FROM U00010;                
end

if object_id('U01010') is not null begin -- Itens Contrato Cemiterio
	TRUNCATE  FROM U01010;                
end

if object_id('U02010') is not null begin -- Autorizados
	TRUNCATE  FROM U02010;                
end


if object_id('U03010') is not null begin -- Mensagens
	TRUNCATE  FROM U03010;                
end

if object_id('U04010') is not null begin -- Enderecamento
	TRUNCATE  FROM U04010;                
end


if object_id('U07010') is not null begin -- Servicos
	TRUNCATE  FROM U07010;                
end

if object_id('U19010') is not null begin -- Log Transferencia Ossario
	TRUNCATE  FROM U19010;                
end

if object_id('U20010') is not null begin -- Reajuste Contrato
	TRUNCATE  FROM U20010;                
end

if object_id('U21010') is not null begin -- Itens Reajuste
	TRUNCATE  FROM U21010;                
end

if object_id('U23010') is not null begin -- Mala Direta
	TRUNCATE  FROM U23010;                
end

if object_id('U25010') is not null begin -- Controle de Locacao de Salas
	TRUNCATE  FROM U25010;                
end

if object_id('U26010') is not null begin -- Hist. Taxa Manutencao
	TRUNCATE  FROM U26010;                
end

if object_id('U27010') is not null begin -- Itens da Manutencao
	TRUNCATE  FROM U27010;                
end


if object_id('U30010') is not null begin -- Historico Gaveta
	TRUNCATE  FROM U30010;                
end

if object_id('U32010') is not null begin -- Cabecalhos de Carnes
	TRUNCATE  FROM U32010;                
end

if object_id('U33010') is not null begin -- Itens do Carne
	TRUNCATE  FROM U33010;                
end

if object_id('U34010') is not null begin -- Cabecalhos de Rotas
	TRUNCATE  FROM U34010;                
end

if object_id('U35010') is not null begin -- Itens da Rota
	TRUNCATE  FROM U35010;                
end

if object_id('U36010') is not null begin -- Servicos Tipos de Plano       
	TRUNCATE  FROM U36010;                
end

if object_id('U37010') is not null begin -- Servicos Contrato
	TRUNCATE  FROM U37010;                
end

if object_id('U38010') is not null begin -- Transferencia de Enderecamento
	TRUNCATE  FROM U38010;                
end

if object_id('UJV010') is not null begin -- Apontamento de Servico
	TRUNCATE  FROM UJV010;                
end

if object_id('UJX010') is not null begin -- Servicos Adicionais
	TRUNCATE  FROM UJx010;                
end

if object_id('U39010') is not null begin -- End. Origem Transferencia
	TRUNCATE  FROM U39010;                
end

if object_id('U40010') is not null begin -- End. Destino Transferencia
	TRUNCATE  FROM U40010;                
end

if object_id('U41010') is not null begin -- Retirada de Cinzas
	TRUNCATE  FROM U41010;                
end

if object_id('U42010') is not null begin -- Log Contratos Cemiterio
	TRUNCATE  FROM U42010;                
end

if object_id('U43010') is not null begin -- Personalizacao de Contratos
	TRUNCATE  FROM U43010;                
end

if object_id('U44010') is not null begin -- Produtos Atuais do Contrato
	TRUNCATE  FROM U44010;                
end

if object_id('U45010') is not null begin -- Servicos Atuais do Contrato
	TRUNCATE  FROM U45010;                
end

if object_id('U47010') is not null begin -- Servicos do novo Plano
	TRUNCATE  FROM U47010;                
end

if object_id('U48010') is not null begin -- Inclusao de Produtos Contrato
	TRUNCATE  FROM U48010;                
end

if object_id('U49010') is not null begin -- Alteracao de Produto Contrato
	TRUNCATE  FROM U49010;                
end

if object_id('U50010') is not null begin -- Exclusao de produtos Contrato
	TRUNCATE  FROM U50010;                
end

if object_id('U51010') is not null begin -- Inclusao de servicos Contrato
	TRUNCATE  FROM U51010;                
end

if object_id('U52010') is not null begin -- Alteracao de servicos Contrato
	TRUNCATE  FROM U52010;
end

if object_id('U53010') is not null begin -- Exclusao servicos Contrato
	TRUNCATE  FROM U53010;
end

if object_id('U56010') is not null begin -- Log Integracao Contratos
	TRUNCATE  FROM U56010;
end

if object_id('U77010') is not null begin -- Historico de Adiantamento de Parcelas
	TRUNCATE  FROM U77010;
end

if object_id('U76010') is not null begin -- Historico de Adiantamento de Parcelas
	TRUNCATE  FROM U76010;
end

if object_id('U75010') is not null begin -- Historico de Adiantamento de Parcelas
	TRUNCATE  FROM U75010;
end

if object_id('U75010') is not null begin -- Historico de Cobranca de Nicho
	TRUNCATE  FROM U75010;
end

if object_id('U74010') is not null begin -- Historico de Cobranca de Nicho
	TRUNCATE  FROM U74010;
end



--//Limpa Funeraria
--if object_id('UF0010') is not null begin
--	TRUNCATE  FROM UF0010;
--end

--if object_id('UF1010') is not null begin
--	TRUNCATE  FROM UF1010;
--end


if object_id('U61010') is not null begin -- Clientes Vindi
	TRUNCATE  FROM U61010;
end

if object_id('U62010') is not null begin -- Lista de Envio Vindi          
	TRUNCATE  FROM U62010;
end

if object_id('U63010') is not null begin -- Lista de Recebimento Vindi            
	TRUNCATE  FROM U63010;
end

if object_id('U64010') is not null begin -- Perfil de Pagamento Vindi               
	TRUNCATE  FROM U64010;
end

if object_id('U65010') is not null begin -- Faturas Vindi                                
	TRUNCATE  FROM U65010;
end

if object_id('U66010') is not null begin -- Tentativas de Cobranca Vindi                               
	TRUNCATE  FROM U66010;
end

if object_id('U68010') is not null begin -- Cabecalho Alteracoes Contrato                             
	TRUNCATE  FROM U68010;
end

if object_id('U69010') is not null begin -- Alteracao Beneficiarios                            
	TRUNCATE  FROM U69010;
end

if object_id('U70010') is not null begin -- Alteracao Cobranca Adic                            
	TRUNCATE  FROM U70010;
end

if object_id('U71010') is not null begin -- Alteracao Produtos e Serv                            
	TRUNCATE  FROM U71010;
end

if object_id('U72010') is not null begin -- Alteracao de Mensagens                           
	TRUNCATE  FROM U72010;
end

if object_id('U73010') is not null begin -- Historico de Alteracao                        
	TRUNCATE  FROM U73010;
end

if object_id('UF2010') is not null begin -- Contratos Funeraria
	TRUNCATE  FROM UF2010;
end

if object_id('UF3010') is not null begin -- Produtos Contrato
	TRUNCATE  FROM UF3010;
end

if object_id('UF4010') is not null begin -- Beneficiarios
	TRUNCATE  FROM UF4010;
end

if object_id('UF5010') is not null begin -- Historico Transf. Titularidade
	TRUNCATE  FROM UF5010;
end

if object_id('UF7010') is not null begin -- Historico de Reajuste Funeraria
	TRUNCATE  FROM UF7010;
end

if object_id('UF8010') is not null begin -- Itens de Reajuste Funeraria
	TRUNCATE  FROM UF8010;
	
end

if object_id('UF9010') is not null begin -- Mensagens Contrato Funerario
	TRUNCATE  FROM UF9010;
end

if object_id('UG0010') is not null begin -- Apontamento Servicos
	TRUNCATE  FROM UG0010;
end

if object_id('UG1010') is not null begin -- Itens Apontamento Servico
	TRUNCATE  FROM UG1010;
end


if object_id('UG8010') is not null begin -- Historico de Add Parcelas
	TRUNCATE  FROM UG8010;
end

if object_id('UG9010') is not null begin -- Itens do Adiantamento
	TRUNCATE  FROM UG9010;
end

if object_id('UGA010') is not null begin -- Log Contratos
	TRUNCATE  FROM UGA010;
end

if object_id('UH0010') is not null begin -- Hist Taxa Manutencao Funeraria 
	TRUNCATE  FROM UH0010;
end

if object_id('UH1010') is not null begin -- Titulos Hist Manutencao
	TRUNCATE  FROM UH1010;
end

if object_id('UH2010') is not null begin -- Personalizacao Contrato
	TRUNCATE  FROM UH2010;
end

if object_id('UH3010') is not null begin -- Produtos Atuais Contrato
	TRUNCATE  FROM UH3010;
end

if object_id('UH4010') is not null begin -- Produtos Novos Contrato
	TRUNCATE  FROM UH4010;
end

if object_id('UH5010') is not null begin -- Inclusao Produtos Contrato
	TRUNCATE  FROM UH5010;
end

if object_id('UH6010') is not null begin -- Alteracao Produtos Contrato
	TRUNCATE  FROM UH6010;
end

if object_id('UH7010') is not null begin -- Exclusao Produtos Contrato
	TRUNCATE  FROM UH7010;
end

if object_id('UJ0010') is not null begin -- Apontamento Servico MOD2
	TRUNCATE  FROM UJ0010;
end

if object_id('UJ1010') is not null begin -- Itens Apontamento Contratado
	TRUNCATE  FROM UJ1010;
end

if object_id('UJ2010') is not null begin -- Itens Apontamento Entregue
	TRUNCATE  FROM UJ2010;
end

if object_id('UJ4010') is not null begin -- Itens Apontamento Transferencia
	TRUNCATE  FROM UJ4010;
end

if object_id('UJH010') is not null begin -- Convalescencia
	TRUNCATE  FROM UJH010;
end

if object_id('UJI010') is not null begin -- Itens Convalescencia
	TRUNCATE  FROM UJI010;
end

if object_id('UJP010') is not null begin -- Historico Ciclo Convalescencia
	TRUNCATE  FROM UJP010;
end

if object_id('UJQ010') is not null begin -- Titulos Ciclo Convalescencia  
	TRUNCATE  FROM UJQ010;
end

if object_id('UJR010') is not null begin -- Regras Contrato Aplicadas     
	TRUNCATE  FROM UJR010;
end

if object_id('UJS010') is not null begin -- Pre Reagendamento Virtus Cobranca    
	TRUNCATE  FROM UJS010;
end

if object_id('UJ9010') is not null begin -- Cobranca adicionais   
	TRUNCATE  FROM UJ9010;
end










