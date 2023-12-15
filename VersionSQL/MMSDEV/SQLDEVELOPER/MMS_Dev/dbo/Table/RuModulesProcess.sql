/****** Object:  Table [dbo].[RuModulesProcess]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.RuModulesProcess(
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
 CONSTRAINT [PK_RuModulesProcess] PRIMARY KEY CLUSTERED 
(
	[RuModulesProcess_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.RuModulesProcess ADD  CONSTRAINT [DF__RuModules__RuMod__49CFAF06]  DEFAULT ((1)) FOR [RuModules_Id]
ALTER TABLE dbo.RuModulesProcess  WITH CHECK ADD  CONSTRAINT [FK__RuModules__RuMod__4BB7F778] FOREIGN KEY([RuModules_Id])
REFERENCES [dbo].[RuModules] ([RuModules_Id])
ALTER TABLE dbo.RuModulesProcess CHECK CONSTRAINT [FK__RuModules__RuMod__4BB7F778]
