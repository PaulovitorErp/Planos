-- Instrucoes para RDS RESTORE
-- https://docs.aws.amazon.com/pt_br/AmazonRDS/latest/UserGuide/SQLServer.Procedural.Importing.html

-- Restaurar banco de dados do AWS Bucket
exec msdb.dbo.rds_restore_database 
	@restore_db_name='VIRTUSERP', 
	@s3_arn_to_restore_from='arn:aws:s3:::postumosbkp/virtuserp.bak',
	@with_norecovery=0,
	@type='FULL';

-- Visualizar status do RESTORE DATABASE
exec msdb.dbo.rds_task_status @db_name='VIRTUSERP';