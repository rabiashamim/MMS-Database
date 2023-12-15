/****** Object:  Table [dbo].[MtPartyRegisteration]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtPartyRegisteration(
	[MtPartyRegisteration_Id] [decimal](18, 0) NOT NULL,
	[MtPartyRegisteration_Name] [varchar](250) NULL,
	[MtPartyRegisteration_Remarks] [varchar](max) NULL,
	[MtPartyRegisteration_IsPowerPool] [bit] NULL,
	[SrPartyType_Code] [varchar](4) NULL,
	[MtPartyRegisteration_CreatedBy] [decimal](18, 0) NOT NULL,
	[MtPartyRegisteration_CreatedOn] [datetime] NOT NULL,
	[MtPartyRegisteration_ModifiedBy] [decimal](18, 0) NULL,
	[MtPartyRegisteration_ModifiedOn] [datetime] NULL,
	[LuStatus_Code_Approval] [varchar](4) NULL,
	[LuStatus_Code_Applicant] [varchar](4) NULL,
	[MtPartyRegisteration_MPId] [varchar](50) NULL,
	[isDeleted] [bit] NULL,
	[MtPartyRegisteration_IsKE] [bit] NULL,
 CONSTRAINT [PK_MtPartyRegisteration] PRIMARY KEY CLUSTERED 
(
	[MtPartyRegisteration_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE dbo.MtPartyRegisteration ADD  DEFAULT ((0)) FOR [isDeleted]
ALTER TABLE dbo.MtPartyRegisteration  WITH CHECK ADD FOREIGN KEY([LuStatus_Code_Approval])
REFERENCES [dbo].[LuStatus] ([LuStatus_Code])
ALTER TABLE dbo.MtPartyRegisteration  WITH CHECK ADD FOREIGN KEY([LuStatus_Code_Applicant])
REFERENCES [dbo].[LuStatus] ([LuStatus_Code])
ALTER TABLE dbo.MtPartyRegisteration  WITH CHECK ADD FOREIGN KEY([SrPartyType_Code])
REFERENCES [dbo].[SrPartyType] ([SrPartyType_Code])

CREATE TRIGGER [dbo].[audittrg_MtPartyRegisteration]
ON dbo.MtPartyRegisteration
AFTER UPDATE
AS
BEGIN

	SET NOCOUNT ON;

	INSERT INTO [dbo].[MtPartyRegisteration_audit] ([MtPartyRegisteration_Id]
	, [MtPartyRegisteration_Name]
	, [MtPartyRegisteration_Remarks]
	, [MtPartyRegisteration_IsPowerPool]
	, [SrPartyType_Code]
	, [MtPartyRegisteration_CreatedBy]
	, [MtPartyRegisteration_CreatedOn]
	, [MtPartyRegisteration_ModifiedBy]
	, [MtPartyRegisteration_ModifiedOn]
	, [LuStatus_Code_Approval]
	, [LuStatus_Code_Applicant]
	, [MtPartyRegisteration_MPId]
	, [isDeleted]
	, [MtPartyRegisteration_IsKE]
	, [updated_at]
	, [operation])
		SELECT
			[MtPartyRegisteration_Id]
		   ,[MtPartyRegisteration_Name]
		   ,[MtPartyRegisteration_Remarks]
		   ,[MtPartyRegisteration_IsPowerPool]
		   ,[SrPartyType_Code]
		   ,[MtPartyRegisteration_CreatedBy]
		   ,[MtPartyRegisteration_CreatedOn]
		   ,[MtPartyRegisteration_ModifiedBy]
		   ,[MtPartyRegisteration_ModifiedOn]
		   ,[LuStatus_Code_Approval]
		   ,[LuStatus_Code_Applicant]
		   ,[MtPartyRegisteration_MPId]
		   ,[isDeleted]
		   ,[MtPartyRegisteration_IsKE]
		   ,GETDATE()
		   ,'ALT'
		FROM DELETED d
-- inserted i
END
ALTER TABLE dbo.MtPartyRegisteration ENABLE TRIGGER [audittrg_MtPartyRegisteration]
