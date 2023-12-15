/****** Object:  Table [dbo].[MtSOFileMaster_audit]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtSOFileMaster_audit(
	[MtSOFileMaster_audit_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
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
	[updated_at] [datetime] NOT NULL,
	[operation] [char](3) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
