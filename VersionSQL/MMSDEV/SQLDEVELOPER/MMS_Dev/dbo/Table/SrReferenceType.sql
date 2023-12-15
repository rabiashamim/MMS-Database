/****** Object:  Table [dbo].[SrReferenceType]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.SrReferenceType(
	[SrReferenceType_Id] [int] IDENTITY(1,1) NOT NULL,
	[SrReferenceType_Name] [varchar](100) NOT NULL,
	[SrReferenceType_Unit] [nvarchar](50) NOT NULL,
	[SrReferenceType_CreatedOn] [datetime] NOT NULL,
	[SrReferenceType_CreatedBy] [decimal](18, 0) NOT NULL,
	[SrReferenceType_ModifiedOn] [datetime] NULL,
	[SrReferenceType_ModifiedBy] [decimal](18, 0) NULL,
	[SrReferenceType_IsDeleted] [bit] NULL,
 CONSTRAINT [PK__SrRefere__216B3CDD99CB96D4] PRIMARY KEY CLUSTERED 
(
	[SrReferenceType_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.SrReferenceType ADD  CONSTRAINT [DF__SrReferen__SrRef__0BB280FC]  DEFAULT ((0)) FOR [SrReferenceType_IsDeleted]

CREATE TRIGGER [dbo].[audittrg_SrReferenceType]
ON dbo.SrReferenceType
AFTER UPDATE
AS
BEGIN
	INSERT INTO [dbo].[SrReferenceType_audit] ([SrReferenceType_Id]
	, [SrReferenceType_Name]
	, [SrReferenceType_Unit]
	, [SrReferenceType_CreatedOn]
	, [SrReferenceType_CreatedBy]
	, [SrReferenceType_ModifiedOn]
	, [SrReferenceType_ModifiedBy]
	, [SrReferenceType_IsDeleted]
	, [updated_at]
	, [operation])
		SELECT
			[SrReferenceType_Id]
		   ,[SrReferenceType_Name]
		   ,[SrReferenceType_Unit]
		   ,[SrReferenceType_CreatedOn]
		   ,[SrReferenceType_CreatedBy]
		   ,[SrReferenceType_ModifiedOn]
		   ,[SrReferenceType_ModifiedBy]
		   ,[SrReferenceType_IsDeleted]
		   ,GETDATE()
		   ,'ALT'
		FROM DELETED d;
END
ALTER TABLE dbo.SrReferenceType ENABLE TRIGGER [audittrg_SrReferenceType]
