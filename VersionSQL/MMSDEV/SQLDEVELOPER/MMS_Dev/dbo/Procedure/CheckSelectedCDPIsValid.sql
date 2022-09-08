/****** Object:  Procedure [dbo].[CheckSelectedCDPIsValid]    Committed by VersionSQL https://www.versionsql.com ******/

--exec CheckSelectedCDPIsValid @vCdpId=1,@vCategoryId=787
-- exec CheckSelectedCDPIsValid @vCdpId=86,@vCategoryId=798
-- CheckSelectedCDPIsValid @vCategoryId=765,@vCdpId=1  
--use MMS  
--exec CheckSelectedCDPIsValid @vCdpId=21,@vCategoryId=765  
  
CREATE PROCEDURE [dbo].[CheckSelectedCDPIsValid]  
  
@vCdpId int=null,            
@vCategoryId int=null  
AS  
BEGIN  
  
declare @vMessages varchar(max);  
  
if Exists(  
             SELECT 1  
             FROM   
              MtConnectedMeter   
             WHERE   
                MtPartyCategory_Id = @vCategoryId  
                AND ISNULL(MtConnectedMeter_isDeleted,0)=0  
    AND MtCDPDetail_Id=@vCdpId  
                AND ISNULL(IsAssigned,0)=1  
   )  
   BEGIN  
   SET @vMessages='This CDP is already selected with this Party'  
    SELECT @vMessages AS ResponseMessage  
 return;  
   END  
  
   declare @countConnectedCDPs int=0;  
   drop table if exists #temp
  Select   
		'('+Convert(VARCHAR(10),PR.MtPartyRegisteration_Id)+')'+PR.MtPartyRegisteration_Name as Names
		into #temp
  FROM  
  MtConnectedMeter  MT
  JOIN MtPartyCategory PC ON PC.MtPartyCategory_Id=MT.MtPartyCategory_Id
  JOIN MtPartyRegisteration PR ON PR.MtPartyRegisteration_Id = PC.MtPartyRegisteration_Id
  WHERE  
	ISNULL(MtConnectedMeter_isDeleted,0)=0  
    AND MtCDPDetail_Id=@vCdpId  
    AND ISNULL(IsAssigned,0)=1  
	AND ISNULL(PC.isDeleted,0)=0
	AND ISNULL(PR.isDeleted,0)=0

	declare @tmp varchar(250)    
SET @tmp = ''    
select @tmp = @tmp + Names + ', ' from #temp    
    
    
    


    Select   
  @countConnectedCDPs =count(1)   
 FROM  
 #temp


   IF (@countConnectedCDPs >1)  
    BEGIN  
  set @vMessages='This CDP is already selected against following parties: '+ (select SUBSTRING(@tmp, 0, LEN(@tmp)) as NoExistsId )
    END  
   SELECT @vMessages AS ResponseMessage  
  
END  
  
  
  
  
  
  
  
