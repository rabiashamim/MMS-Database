/****** Object:  Procedure [dbo].[CheckCDPIds]    Committed by VersionSQL https://www.versionsql.com ******/

-- CheckCDPIds '1000,1,2000'    
    
CREATE PROCEDURE  [dbo].[CheckCDPIds]    
@pCdpIds VARCHAR(max)    
AS    
BEGIN    
    
select value     
into #temp    
from     
 string_split(@pCdpIds,',')    
WHERE    
 value not in (    
     select distinct (RuCDPDetail_CdpId)  from RuCDPDetail    
   )    
    
declare @tmp varchar(250)    
SET @tmp = ''    
select @tmp = @tmp + value + ', ' from #temp    
    
    
    
select SUBSTRING(@tmp, 0, LEN(@tmp)) as NoExistsId    
    
    
END
