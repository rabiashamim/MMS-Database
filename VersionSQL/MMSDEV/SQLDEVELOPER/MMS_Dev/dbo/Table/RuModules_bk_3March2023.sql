/****** Object:  Table [dbo].[RuModules_bk_3March2023]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.RuModules_bk_3March2023(
	[RuModules_Id] [int] IDENTITY(1,1) NOT NULL,
	[RuModules_Name] [varchar](100) NULL,
	[RuModules_IsActive] [bit] NULL,
	[RuModules_CreatedBy] [decimal](18, 0) NOT NULL,
	[RuModules_CreatedOn] [datetime] NOT NULL,
	[RuModules_ModifiedBy] [decimal](18, 0) NULL,
	[RuModules_ModifiedOn] [datetime] NULL,
	[RuModules_IsDeleted] [bit] NULL,
	[RuModules_IsVisible] [bit] NULL
) ON [PRIMARY]
