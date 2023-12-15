/****** Object:  Table [dbo].[RuModules]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.RuModules(
	[RuModules_Id] [int] NOT NULL,
	[RuModules_Name] [varchar](100) NULL,
	[RuModules_IsActive] [bit] NULL,
	[RuModules_CreatedBy] [decimal](18, 0) NOT NULL,
	[RuModules_CreatedOn] [datetime] NOT NULL,
	[RuModules_ModifiedBy] [decimal](18, 0) NULL,
	[RuModules_ModifiedOn] [datetime] NULL,
	[RuModules_IsDeleted] [bit] NULL,
	[RuModules_IsVisible] [bit] NULL,
 CONSTRAINT [PK__RuModule__7CA6C76084583C2C] PRIMARY KEY CLUSTERED 
(
	[RuModules_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
