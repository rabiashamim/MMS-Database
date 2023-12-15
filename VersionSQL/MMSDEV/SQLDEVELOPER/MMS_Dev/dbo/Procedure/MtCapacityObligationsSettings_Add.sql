/****** Object:  Procedure [dbo].[MtCapacityObligationsSettings_Add]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author: Ali Imran
-- CREATE date: May 16, 2023 
-- ALTER date:   
-- Description: This Stored Procedure inserts a new record in Table "MtCapacityObligationsSettings".
-- [MtCapacityObligationsSettings_Add] 0,1,1,'1/1/2021',null,1
-- select * from [MtCapacityObligationsSettings]
-- =============================================   

CREATE   PROCEDURE dbo.MtCapacityObligationsSettings_Add
	@MtCapacityObligationsSettings_Id	Decimal(18, 0) OUTPUT,
	@MtCapacityObligationsSettings_year	Int,
	@MtCapacityObligationsSettings_Percentage	Decimal(18, 5),
	@SrCategory_Code VARCHAR(4),
	@MtCapacityObligationsSettings_EffectiveFrom	DateTime,
	@MtCapacityObligationsSettings_EffectiveTo	DateTime = NULL,
	@MtCapacityObligationsSettings_CreatedBy	Decimal(18, 0)
AS
               
	INSERT INTO [MtCapacityObligationsSettings]
	(
		[MtCapacityObligationsSettings_year],
		[MtCapacityObligationsSettings_Percentage],
		[SrCategory_Code],
		[MtCapacityObligationsSettings_EffectiveFrom],
		[MtCapacityObligationsSettings_EffectiveTo],
		[MtCapacityObligationsSettings_CreatedBy]
	)
	VALUES
	(
		@MtCapacityObligationsSettings_year,
		@MtCapacityObligationsSettings_Percentage,
		@SrCategory_Code,
		@MtCapacityObligationsSettings_EffectiveFrom,
		@MtCapacityObligationsSettings_EffectiveTo,
		@MtCapacityObligationsSettings_CreatedBy
   )
	
	SET @MtCapacityObligationsSettings_Id = SCOPE_IDENTITY()
