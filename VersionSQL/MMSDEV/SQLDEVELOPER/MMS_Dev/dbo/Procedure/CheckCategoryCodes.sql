/****** Object:  Procedure [dbo].[CheckCategoryCodes]    Committed by VersionSQL https://www.versionsql.com ******/

    
CREATE PROCEDURE  [dbo].[CheckCategoryCodes]    
@pCodes VARCHAR(max)    
AS    
BEGIN    
    
select value     
into #temp    
from     
 string_split(@pCodes,',')    
WHERE    
 value not in (    
     select distinct (SrCategory_Code)  from SrCategory    
   )    
    
declare @tmp varchar(250)    
SET @tmp = ''    
select @tmp = @tmp + value + ', ' from #temp    
    
    
    
select SUBSTRING(@tmp, 0, LEN(@tmp)) as NoExistsId    
    
    
END
