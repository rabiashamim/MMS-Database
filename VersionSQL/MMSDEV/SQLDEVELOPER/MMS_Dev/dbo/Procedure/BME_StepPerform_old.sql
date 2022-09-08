/****** Object:  Procedure [dbo].[BME_StepPerform_old]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
 CREATE PROCEDURE [dbo].[BME_StepPerform_old](			 
			@ProcessId int,
			@StepId int,
			@Month int,
			@Year int)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

 declare @sourceColumns nvarchar(max), @targetColumns nvarchar(max),
@query nvarchar(max);
select @sourceColumns = ISNULL(@sourceColumns +',','')+ QUOTENAME(rtrim(MappedWithColumn)),@targetColumns = ISNULL(@targetColumns+',','')+ QUOTENAME(rtrim(MappedWithColumn)) from [Settlement].ComponentDef where StepID=@StepId;

--set @query='Select '+@sourceColumns+' from [Settlement].StatementData';
set @query='insert into Table_2 (a) 
select a from Table_1';

exec (@query);

END
