/****** Object:  Procedure [dbo].[MmsErpAcknowledge]    Committed by VersionSQL https://www.versionsql.com ******/

--select * from MmsErpSettlementsIntegration    --View 


CREATE PROCEDURE MmsErpAcknowledge
@MMS_INT_ID decimal(18,0),
@TT_ERP bit	=0,
@RF_MMS bit=0
 AS
BEGIN
UPDATE [dbo].[MmsErpData] set 
MmsErpData_TransferedToERP=@TT_ERP,
MmsErpData_ReadFromMms=@RF_MMS
where 
MmsErpData_Id=@MMS_INT_ID;

END
