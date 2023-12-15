/****** Object:  Table [dbo].[RuModulesProcess_bk_3March2023]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.RuModulesProcess_bk_3March2023(
	[RuModulesProcess_Id] [int] NOT NULL,
	[RuModulesProcess_Name] [varchar](128) NULL,
	[RuModulesProcess_IsActive] [bit] NULL,
	[RuModulesProcess_CreatedBy] [decimal](18, 0) NULL,
	[RuModulesProcess_CreatedOn] [datetime] NULL,
	[RuModulesProcess_ModifiedBy] [decimal](18, 0) NULL,
	[RuModulesProcess_ModifiedOn] [datetime] NULL,
	[RuModulesProcess_IsDeleted] [bit] NULL,
	[RuModules_Id] [int] NOT NULL,
	[RuModulesProcess_LinkedObject] [varchar](100) NULL,
	[RuModulesProcess_ProcessTemplateId] [int] NULL,
	[RuModulesProcess_WhereClause] [varchar](64) NULL
) ON [PRIMARY]
