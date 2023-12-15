/****** Object:  Table [dbo].[test_triggera]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.test_triggera(
	[id] [int] NULL,
	[name] [varchar](32) NULL
) ON [PRIMARY]

CREATE trigger test_triggera_trigg      
on test_triggera     
after update    
as    
select * from inserted  
select * from deleted  
  
update test_trigger    
set name='upd11'    
where id in (1,2)  
select * from inserted  
select * from deleted
ALTER TABLE dbo.test_triggera ENABLE TRIGGER [test_triggera_trigg]
