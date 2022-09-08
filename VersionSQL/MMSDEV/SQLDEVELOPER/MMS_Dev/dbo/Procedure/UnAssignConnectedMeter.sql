/****** Object:  Procedure [dbo].[UnAssignConnectedMeter]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[UnAssignConnectedMeter]
@vconnectedMeterId decimal(18,0)
AS
BEGIN

   declare @vMtCDPDetail_Id decimal(18,0);
   
  select 
       @vMtCDPDetail_Id = MtCDPDetail_Id 
 from 
      MtConnectedMeter 
 Where 
     MtConnectedMeter_Id=@vconnectedMeterId

  update  MtConnectedMeter SET IsAssigned=0, mtconnectedmeter_effectiveto = getutcdate() where MtConnectedMeter_Id=@vconnectedMeterId


  update  MtCDPDetail SET IsAssigned=0 where MtCDPDetail_Id=@vMtCDPDetail_Id

  

      
END
