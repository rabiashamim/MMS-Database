/****** Object:  Procedure [dbo].[InsertMailLog]    Committed by VersionSQL https://www.versionsql.com ******/

    
CREATE PROCEDURE dbo.InsertMailLog    
 @WorkflowHeaderID int,  
    @ToResource varchar(255),  
    @MailSubject varchar(Max)  
  
AS    
BEGIN    
INSERT INTO MailLog(MailID,  
WorkflowHeaderID,  
ToResource,  
MailSubject,  
SentDate)   
VALUES  
((SELECT IsNull(MAX(MailID) + 1,1) from MailLog),  
@WorkflowHeaderID,  
@ToResource,  
@MailSubject,  
(SELECT GETDATE())  
)    
END 
