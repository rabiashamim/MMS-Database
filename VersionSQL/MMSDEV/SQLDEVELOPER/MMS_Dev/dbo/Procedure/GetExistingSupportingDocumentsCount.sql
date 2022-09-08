/****** Object:  Procedure [dbo].[GetExistingSupportingDocumentsCount]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[GetExistingSupportingDocumentsCount]
@pPartyRegistrationId decimal(18,0),
@pRegistrationActivityId decimal(18,0),
@pDocumentFormId int
AS
BEGIN

	select RD.RuDocuments_Id,RD.RuDocuments_Name, count(MD.RuDocument_ID) AS Total_Documents 
	into #temp
	from RuDocuments RD 
		left join MtDocuments MD on RD.RuDocuments_Id = MD.RuDocument_ID 
		left join MtRegisterationActivities mra on md.MtRegisterationActivity_Id = mra.MtRegisterationActivity_Id 
	where mra.MtPartyRegisteration_Id = @pPartyRegistrationId 
		and rd.RuDocuments_Id = @pDocumentFormId and ISNULL(md.MtDocuments_isDeleted,0)= 0 
		and md.MtRegisterationActivity_Id = @pRegistrationActivityId  
	group by RD.RuDocuments_Id,RD.RuDocuments_Name,MD.RuDocument_ID

	if exists(
	select 1 from #temp
	)
	bEGIN

		select * from #temp 
	END
	else
	bEGIN
		select @pDocumentFormId as RuDocuments_Id, 'Supporting Dcoument' as	RuDocuments_Name , 0 as	Total_Documents
		
	END

	RETURN;
END
