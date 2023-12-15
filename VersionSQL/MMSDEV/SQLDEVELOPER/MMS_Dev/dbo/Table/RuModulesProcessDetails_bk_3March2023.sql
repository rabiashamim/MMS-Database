/****** Object:  Table [dbo].[RuModulesProcessDetails_bk_3March2023]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.RuModulesProcessDetails_bk_3March2023(
	[RuModulesProcessDetails_Id] [int] NULL,
	[RuModulesProcess_Id] [int] NOT NULL,
	[RuModulesProcessDetails_ColumnName] [varchar](128) NULL,
	[RuModulesProcessDetails_Label] [nvarchar](256) NULL,
	[RuModulesProcessDetails_CreatedBy] [decimal](18, 0) NULL,
	[RuModulesProcessDetails_CreatedOn] [datetime] NULL,
	[RuModulesProcessDetails_ModifiedBy] [decimal](18, 0) NULL,
	[RuModulesProcessDetails_ModifiedOn] [datetime] NULL,
	[RuModulesProcessDetails_IsDeleted] [bit] NULL,
	[RuModulesProcessDetails_IsSubject] [bit] NULL,
	[RuModulesProcessDetails_IsWhere] [bit] NULL
) ON [PRIMARY]
