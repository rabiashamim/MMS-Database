/****** Object:  Table [dbo].[MtSOFileMaster]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtSOFileMaster(
	[MtSOFileMaster_Id] [decimal](18, 0) NOT NULL,
	[LuSOFileTemplate_Id] [int] NOT NULL,
	[LuAccountingMonth_Id] [int] NOT NULL,
	[MtSOFileMaster_FileName] [varchar](max) NULL,
	[MtSOFileMaster_CreatedBy] [int] NOT NULL,
	[MtSOFileMaster_CreatedOn] [datetime] NOT NULL,
	[MtSOFileMaster_ModifiedBy] [int] NULL,
	[MtSOFileMaster_ModifiedOn] [datetime] NULL,
	[MtSOFileMaster_IsDeleted] [bit] NULL,
	[MtSOFileMaster_FilePath] [varchar](max) NULL,
	[LuStatus_Code] [varchar](4) NULL,
	[MtSOFileMaster_Version] [int] NULL,
	[MtSOFileMaster_IsUseForSettlement] [bit] NULL,
	[MtSOFileMaster_Description] [varchar](max) NULL,
	[InvalidRecords] [bigint] NULL,
	[TotalRecords] [bigint] NULL,
	[MtSOFileMaster_ApprovalStatus] [varchar](16) NULL,
	[LuDataConfiguration_Id] [int] NOT NULL,
	[MtSOFileMaster_Validations] [varchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[MtSOFileMaster_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE dbo.MtSOFileMaster ADD  DEFAULT ((0)) FOR [MtSOFileMaster_IsUseForSettlement]
ALTER TABLE dbo.MtSOFileMaster ADD  DEFAULT (NULL) FOR [MtSOFileMaster_Description]
ALTER TABLE dbo.MtSOFileMaster ADD  DEFAULT ((1)) FOR [LuDataConfiguration_Id]
ALTER TABLE dbo.MtSOFileMaster  WITH CHECK ADD FOREIGN KEY([LuAccountingMonth_Id])
REFERENCES [dbo].[LuAccountingMonth] ([LuAccountingMonth_Id])
ALTER TABLE dbo.MtSOFileMaster  WITH CHECK ADD FOREIGN KEY([LuDataConfiguration_Id])
REFERENCES [dbo].[LuDataConfiguration] ([LuDataConfiguration_Id])
ALTER TABLE dbo.MtSOFileMaster  WITH CHECK ADD FOREIGN KEY([LuSOFileTemplate_Id])
REFERENCES [dbo].[LuSOFileTemplate] ([LuSOFileTemplate_Id])
CREATE TRIGGER [dbo].[audittrg_MtSOFileMaster]
ON dbo.MtSOFileMaster
AFTER UPDATE
AS
BEGIN
	INSERT INTO MtSOFileMaster_audit (MtSOFileMaster_Id, LuSOFileTemplate_Id, LuAccountingMonth_Id, MtSOFileMaster_FileName, MtSOFileMaster_CreatedBy, MtSOFileMaster_CreatedOn, MtSOFileMaster_ModifiedBy, MtSOFileMaster_ModifiedOn, MtSOFileMaster_IsDeleted, MtSOFileMaster_FilePath, LuStatus_Code, MtSOFileMaster_Version, MtSOFileMaster_IsUseForSettlement, MtSOFileMaster_Description, InvalidRecords, TotalRecords, MtSOFileMaster_ApprovalStatus, LuDataConfiguration_Id, updated_at, operation)
		SELECT
			MtSOFileMaster_Id
		   ,LuSOFileTemplate_Id
		   ,LuAccountingMonth_Id
		   ,MtSOFileMaster_FileName
		   ,MtSOFileMaster_CreatedBy
		   ,MtSOFileMaster_CreatedOn
		   ,MtSOFileMaster_ModifiedBy
		   ,MtSOFileMaster_ModifiedOn
		   ,MtSOFileMaster_IsDeleted
		   ,MtSOFileMaster_FilePath
		   ,LuStatus_Code
		   ,MtSOFileMaster_Version
		   ,MtSOFileMaster_IsUseForSettlement
		   ,MtSOFileMaster_Description
		   ,InvalidRecords
		   ,TotalRecords
		   ,MtSOFileMaster_ApprovalStatus
		   ,LuDataConfiguration_Id
		   ,GETDATE()
		   ,'ALT'
		FROM DELETED d;
END
ALTER TABLE dbo.MtSOFileMaster ENABLE TRIGGER [audittrg_MtSOFileMaster]
