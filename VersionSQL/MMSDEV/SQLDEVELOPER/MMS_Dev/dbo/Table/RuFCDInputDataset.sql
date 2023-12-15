/****** Object:  Table [dbo].[RuFCDInputDataset]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.RuFCDInputDataset(
	[RuFCDInputDataset_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[RuFCDInputDataset_Name] [varchar](250) NOT NULL,
	[RuFCDInputDataset_SourceTable] [varchar](100) NULL,
	[LuSOFileTemplate_Id] [int] NULL,
	[RuFCDInputDataset_Description] [nvarchar](250) NULL,
	[RuFCDInputDataset_CreatedBy] [int] NOT NULL,
	[RuFCDInputDataset_CreatedOn] [datetime] NOT NULL,
	[RuFCDInputDataset_ModifiedBy] [int] NULL,
	[RuFCDInputDataset_ModifiedOn] [datetime] NULL,
	[RuFCDInputDataset_IsDeleted] [bit] NULL,
	[SrFCDProcessDef_Id] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[RuFCDInputDataset_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.RuFCDInputDataset ADD  DEFAULT ((0)) FOR [RuFCDInputDataset_IsDeleted]
ALTER TABLE dbo.RuFCDInputDataset  WITH CHECK ADD FOREIGN KEY([LuSOFileTemplate_Id])
REFERENCES [dbo].[LuSOFileTemplate] ([LuSOFileTemplate_Id])
ALTER TABLE dbo.RuFCDInputDataset  WITH CHECK ADD FOREIGN KEY([SrFCDProcessDef_Id])
REFERENCES [dbo].[SrFCDProcessDef] ([SrFCDProcessDef_Id])
