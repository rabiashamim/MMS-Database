/****** Object:  Procedure [dbo].[UpdateAspNetUsers]    Committed by VersionSQL https://www.versionsql.com ******/

--======================================================================
--Author  : Babar Hussain
--Reviewer : <>
--CreatedDate : 9 March 2022
--Comments : FOR updating users details
-- UpdateAspNetUsers 1,1,2,1,'admin@cppa.gov.pk'
--======================================================================
CREATE PROCEDURE [dbo].[UpdateAspNetUsers]

@pUserId INT,  
@pDesignationId decimal (18,0),    
@pDepartmentId decimal (18,0),  
@pEmail varchar(100),
@pIsEnabled bit,
@pReportToId decimal (18,0) = null
AS
BEGIN

/**********************************************************************************************
Update user Details
**********************************************************************************************/
UPDATE AspNetUsers SET   
 Lu_Designation_Id = @pDesignationId,  
 Lu_ReportTo = @pReportToId,  
 Lu_Department_Id = @pDepartmentId,  
 Email = @pEmail,
 is_enabled = @pIsEnabled
WHERE UserId=@pUserId  

END
