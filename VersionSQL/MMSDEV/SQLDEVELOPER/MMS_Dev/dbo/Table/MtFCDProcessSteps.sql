/****** Object:  Table [dbo].[MtFCDProcessSteps]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtFCDProcessSteps(
	[MtFCDProcessSteps_ID] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtFCDProcessSteps_Status] [bit] NULL,
	[MtFCDProcessSteps_Description] [varchar](100) NULL,
	[MtFCDMaster_ID] [decimal](18, 0) NOT NULL,
	[RuFCDStepDef_ID] [decimal](18, 0) NOT NULL,
	[MtFCDProcessSteps_CreatedBy] [int] NOT NULL,
	[MtFCDProcessSteps_CreatedOn] [datetime] NOT NULL,
	[MtFCDProcessSteps_ModifiedBy] [int] NULL,
	[MtFCDProcessSteps_ModifiedOn] [datetime] NULL,
	[MtFCDProcessSteps_IsDeleted] [bit] NULL,
	[SrFCDProcessDef_Id] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[MtFCDProcessSteps_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.MtFCDProcessSteps ADD  DEFAULT ((0)) FOR [MtFCDProcessSteps_IsDeleted]
ALTER TABLE dbo.MtFCDProcessSteps  WITH CHECK ADD FOREIGN KEY([RuFCDStepDef_ID])
REFERENCES [dbo].[RuFCDStepDef] ([RuFCDStepDef_ID])
ALTER TABLE dbo.MtFCDProcessSteps  WITH CHECK ADD FOREIGN KEY([SrFCDProcessDef_Id])
REFERENCES [dbo].[SrFCDProcessDef] ([SrFCDProcessDef_Id])
