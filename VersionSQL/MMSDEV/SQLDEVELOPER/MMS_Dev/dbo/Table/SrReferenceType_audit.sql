/****** Object:  Table [dbo].[SrReferenceType_audit]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.SrReferenceType_audit(
	[SrReferenceType_audit_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[SrReferenceType_Id] [int] NOT NULL,
	[SrReferenceType_Name] [varchar](100) NOT NULL,
	[SrReferenceType_Unit] [nvarchar](50) NOT NULL,
	[SrReferenceType_CreatedOn] [datetime] NOT NULL,
	[SrReferenceType_CreatedBy] [decimal](18, 0) NOT NULL,
	[SrReferenceType_ModifiedOn] [datetime] NULL,
	[SrReferenceType_ModifiedBy] [decimal](18, 0) NULL,
	[SrReferenceType_IsDeleted] [bit] NULL,
	[updated_at] [datetime] NOT NULL,
	[operation] [char](3) NOT NULL
) ON [PRIMARY]
