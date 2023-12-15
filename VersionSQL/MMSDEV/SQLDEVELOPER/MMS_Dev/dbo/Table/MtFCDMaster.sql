/****** Object:  Table [dbo].[MtFCDMaster]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtFCDMaster(
	[MtFCDMaster_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtFCDMaster_Type] [int] NULL,
	[MtFCDMaster_Months] [nvarchar](max) NOT NULL,
	[MtFCDMaster_Hours] [nvarchar](max) NOT NULL,
	[MtFCDMaster_ProcessStatus] [varchar](20) NULL,
	[MtFCDMaster_ApprovalStatus] [varchar](20) NULL,
	[MtFCDMaster_CreatedBy] [int] NOT NULL,
	[MtFCDMaster_CreatedOn] [datetime] NOT NULL,
	[MtFCDMaster_ModifiedBy] [int] NULL,
	[MtFCDMaster_ModifiedOn] [datetime] NULL,
	[MtFCDMaster_IsDeleted] [bit] NOT NULL,
	[LuAccountingMonth_Id] [int] NULL,
	[SrFCDProcessDef_Id] [int] NULL,
	[MtFCDMaster_ExecutionStartDate] [datetime] NULL,
 CONSTRAINT [PK__MtFCDMas__25157804FE01D20C] PRIMARY KEY CLUSTERED 
(
	[MtFCDMaster_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE dbo.MtFCDMaster ADD  DEFAULT ((0)) FOR [MtFCDMaster_IsDeleted]
ALTER TABLE dbo.MtFCDMaster  WITH CHECK ADD FOREIGN KEY([SrFCDProcessDef_Id])
REFERENCES [dbo].[SrFCDProcessDef] ([SrFCDProcessDef_Id])
