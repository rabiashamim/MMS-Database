/****** Object:  Procedure [dbo].[CheckPartyRegisterationIds]    Committed by VersionSQL https://www.versionsql.com ******/

-- CheckPartyRegisterationIds '1000,1,2000'  
  
CREATE PROCEDURE  [dbo].[CheckPartyRegisterationIds]  
@pPartyRegisterationIds VARCHAR(max)  
AS  
BEGIN  
  
select value   
into #temp  
from   
 string_split(@pPartyRegisterationIds,',')  
WHERE  
 value not in (  
     select distinct (MtPartyRegisteration_Id)  from MtPartyRegisteration  
   )  
  
declare @tmp varchar(250)  
SET @tmp = ''  
select @tmp = @tmp + value + ', ' from #temp  
  
  
  
select SUBSTRING(@tmp, 0, LEN(@tmp)) as NoExistsId  
  
  
END
