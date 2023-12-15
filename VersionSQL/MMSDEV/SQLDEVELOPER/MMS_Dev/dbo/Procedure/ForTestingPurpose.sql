/****** Object:  Procedure [dbo].[ForTestingPurpose]    Committed by VersionSQL https://www.versionsql.com ******/

 --======================================================================        
--Author  : Kapil Kumar        
--Reviewer : <>        
--CreatedDate : 22 Dec 2022        
--Comments :         
--======================================================================        
--use mms        
-- [dbo].[GETCDPsList]  1060      
 CREATE PROCEDURE dbo.ForTestingPurpose              
   
 AS              
 BEGIN              
	
	Select MtGenerator_Id, MtGenerator_Name, MtGenerator_TotalInstalledCapacity, MtGenerator_EffectiveFrom, MtGenerator_EffectiveTo, MtGenerator_Location from MtGenerator

 END      
