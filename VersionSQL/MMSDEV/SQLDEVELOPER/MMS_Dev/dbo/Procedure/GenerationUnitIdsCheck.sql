/****** Object:  Procedure [dbo].[GenerationUnitIdsCheck]    Committed by VersionSQL https://www.versionsql.com ******/

-- GenerationUnitIdsCheck '1000,1,2000'  
  
CREATE PROCEDURE  [dbo].[GenerationUnitIdsCheck]  
@pGenerationUnitIds VARCHAR(max)  
AS  
BEGIN  
  
select value   
into #temp  
from   
 string_split(@pGenerationUnitIds,',')  
WHERE  
 value not in (  
     select distinct (MtGenerationUnit_SOUnitId)  from MtGenerationUnit  WHERE ISNULL(isDeleted,0)=0
   )  
  
declare @tmp varchar(250)  
SET @tmp = ''  
select @tmp = @tmp + value + ', ' from #temp  
  
  
  
select SUBSTRING(@tmp, 0, LEN(@tmp)) as NoExistsId  
  
  
END
