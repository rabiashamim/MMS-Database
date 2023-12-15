/****** Object:  Procedure [dbo].[Sp_GetGlobalSetting]    Committed by VersionSQL https://www.versionsql.com ******/

  -- =============================================
-- Author:Aymen Khalid
-- Create date:05-DEC-2022
-- Description:	<Get Global Setting value on Key and Name>
-- =============================================
CREATE PROCEDURE dbo.Sp_GetGlobalSetting

	@ps_SettingKey varchar(255),
	@ps_SettingName varchar(255)
  
   
AS  
BEGIN  

Declare @Value int 

    SELECT @Value = rg.RuGlobalSetting_value
	 FROM 
		RuGlobalSetting rg 
	WHERE 
		rg.RuGlobalSetting_Name=@ps_SettingName 
	AND rg.RuGlobalSetting_Key = @ps_SettingKey 

	SELECT @Value Value
END  
