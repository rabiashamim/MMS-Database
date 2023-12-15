/****** Object:  Table [dbo].[RuModulesProcessDetails]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.RuModulesProcessDetails(
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
	[RuModulesProcessDetails_IsWhere] [bit] NULL,
	[RuModulesProcess_ShowOnScreen] [int] NULL
) ON [PRIMARY]

ALTER TABLE dbo.RuModulesProcessDetails ADD  DEFAULT ((1)) FOR [RuModulesProcess_ShowOnScreen]
ALTER TABLE dbo.RuModulesProcessDetails  WITH CHECK ADD FOREIGN KEY([RuModulesProcess_Id])
REFERENCES [dbo].[RuModulesProcess] ([RuModulesProcess_Id])
