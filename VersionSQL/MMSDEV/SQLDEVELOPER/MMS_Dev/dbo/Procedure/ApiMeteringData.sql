/****** Object:  Procedure [dbo].[ApiMeteringData]    Committed by VersionSQL https://www.versionsql.com ******/

-- [dbo].[ApiMeteringData]
CREATE PROCEDURE [dbo].[ApiMeteringData]
AS
BEGIN

SET NOCOUNT ON;


--------------------------------------- Parameter Creation
DECLARE @vURL nvarchar(max);
DECLARE @vApiKey nvarchar(max);
DECLARE @vAction nvarchar(max);
DECLARE @vStartTime nvarchar(15);-- datetime;
DECLARE @vEndTime nvarchar(15)--datetime;
Declare @vParametres VARCHAR(max)
Declare @json as table(Json_Table nvarchar(max))--Temp table to store results returned from API
Declare @Object as Int;
DECLARE @hr int
Declare @vBody as varchar(8000) = 
'{
    "api_key": "4babdd93-cf6f-4445-9334-c141457c3c8c",
    "action": "getBVMMeteringDataHalfHourly",
    "start_time": "01-01-2022 00:30:30",
    "end_time": "02-01-2022 00:00:00"
}'  


set @vApiKey='4babdd93-cf6f-4445-9334-c141457c3c8c';
set @vAction='getBVMMeteringDataHalfHourly';
--set @vStartTime='2022-01-01 00:30:30';
set @vStartTime=dateadd(DD, -10, cast(getdate() as date));  
--set @vEndTime='2022-01-02 00:00:00';
set @vStartTime=dateadd(DD, -9, cast(getdate() as date)); 

set @vURL='https://meter.ntdc.com.pk/MetersStatusP/CPPARestAPI/'

SET @vParametres = 'api_key=' + @vApiKey
SET @vParametres = @vParametres + '&action=' + @vAction
SET @vParametres = @vParametres + '&start_time=' +@vStartTime
SET @vParametres = @vParametres + '&end_time=' + @vEndTime



------------------------	Rest API Call starts here
			DELETE FROM @JSON
			print @vURL;


			Exec @hr=sp_OACreate 'MSXML2.ServerXMLHTTP.6.0', @Object OUT;
			IF @hr <> 0 EXEC sp_OAGetErrorInfo @Object
			Exec @hr=sp_OAMethod @Object, 'open', NULL, 'post',
					@vURL, --Your Web Service Url (invoked)
					'false'
			IF @hr <> 0 EXEC sp_OAGetErrorInfo @Object
--			Exec @hr=sp_OAMethod @Object, 'send',null,@vBody
exec sp_OAMethod @object, 'setRequestHeader', null, 'api_key', '4babdd93-cf6f-4445-9334-c141457c3c8c'
exec sp_OAMethod @object, 'setRequestHeader', null, 'action', 'getBVMMeteringDataHalfHourly'
exec sp_OAMethod @object, 'setRequestHeader', null, 'start_time', '01-01-2022 00:30:30'
exec sp_OAMethod @object, 'setRequestHeader', null, 'end_time', '02-01-2022 00:00:00'


			IF @hr <> 0 EXEC sp_OAGetErrorInfo @Object
Exec sp_OAMethod @Object, 'setRequestHeader', null, 'Content-Type', 'application/x-www-form-urlencoded'

			Exec @hr=sp_OAMethod @Object, 'responseText', @json OUTPUT
			IF @hr <> 0 EXEC sp_OAGetErrorInfo @Object

			INSERT into @json (Json_Table) exec sp_OAGetProperty @Object, 'responseText'

select * from @json

END
