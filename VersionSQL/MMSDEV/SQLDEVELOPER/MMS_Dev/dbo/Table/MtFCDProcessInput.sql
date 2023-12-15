/****** Object:  Table [dbo].[MtFCDProcessInput]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtFCDProcessInput(
	[MtFCDProcessInput_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[RuFCDInputDataset_Id] [decimal](18, 0) NULL,
	[MtFCDMaster_Id] [decimal](18, 0) NULL,
	[MtFCDProcessInput_Version] [int] NULL,
	[MtFCDProcessInput_CreatedOn] [datetime] NOT NULL,
	[MtFCDProcessInput_CreatedBy] [int] NOT NULL,
	[MtFCDProcessInput_ModifiedOn] [datetime] NULL,
	[MtFCDProcessInput_ModifiedBy] [int] NULL,
	[MtFCDProcessInput_IsDeleted] [bit] NULL,
	[SrFCDProcessDef_Id] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[MtFCDProcessInput_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.MtFCDProcessInput ADD  DEFAULT ((0)) FOR [MtFCDProcessInput_IsDeleted]
ALTER TABLE dbo.MtFCDProcessInput  WITH CHECK ADD FOREIGN KEY([MtFCDMaster_Id])
REFERENCES [dbo].[MtFCDMaster] ([MtFCDMaster_Id])
ALTER TABLE dbo.MtFCDProcessInput  WITH CHECK ADD FOREIGN KEY([RuFCDInputDataset_Id])
REFERENCES [dbo].[RuFCDInputDataset] ([RuFCDInputDataset_Id])
ALTER TABLE dbo.MtFCDProcessInput  WITH CHECK ADD FOREIGN KEY([SrFCDProcessDef_Id])
REFERENCES [dbo].[SrFCDProcessDef] ([SrFCDProcessDef_Id])
