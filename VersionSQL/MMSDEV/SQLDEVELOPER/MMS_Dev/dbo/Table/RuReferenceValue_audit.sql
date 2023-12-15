/****** Object:  Table [dbo].[RuReferenceValue_audit]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.RuReferenceValue_audit(
	[RuReferenceValue_audit_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[RuReferenceValue_Id] [int] NOT NULL,
	[SrReferenceType_Id] [int] NOT NULL,
	[RuReferenceValue_Value] [decimal](24, 8) NULL,
	[RuReferenceValue_EffectiveFrom] [datetime] NOT NULL,
	[RuReferenceValue_EffectiveTo] [datetime] NOT NULL,
	[RuReferenceValue_CreatedOn] [datetime] NOT NULL,
	[RuReferenceValue_CreatedBy] [decimal](18, 0) NOT NULL,
	[RuReferenceValue_ModifiedOn] [datetime] NULL,
	[RuReferenceValue_ModifiedBy] [decimal](18, 0) NULL,
	[RuReferenceValue_IsDeleted] [bit] NULL,
	[updated_at] [datetime] NOT NULL,
	[operation] [char](3) NOT NULL
) ON [PRIMARY]
