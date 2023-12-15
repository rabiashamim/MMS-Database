/****** Object:  Table [dbo].[RuFCDStepDef]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.RuFCDStepDef(
	[RuFCDStepDef_ID] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[RuFCDStepDef_Name] [nvarchar](max) NULL,
	[RuFCDStepDef_FCDStepNo] [decimal](18, 4) NULL,
	[RuFCDStepDef_CreatedBy] [decimal](18, 0) NULL,
	[RuFCDStepDef_CreatedOn] [datetime] NULL,
	[RuFCDStepDef_ModifiedBy] [decimal](18, 0) NULL,
	[RuFCDStepDef_ModifiedOn] [datetime] NULL,
	[RuFCDStepDef_IsDeleted] [bit] NULL,
	[SrFCDProcessDef_Id] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[RuFCDStepDef_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE dbo.RuFCDStepDef ADD  DEFAULT ((0)) FOR [RuFCDStepDef_IsDeleted]
ALTER TABLE dbo.RuFCDStepDef  WITH CHECK ADD FOREIGN KEY([SrFCDProcessDef_Id])
REFERENCES [dbo].[SrFCDProcessDef] ([SrFCDProcessDef_Id])
