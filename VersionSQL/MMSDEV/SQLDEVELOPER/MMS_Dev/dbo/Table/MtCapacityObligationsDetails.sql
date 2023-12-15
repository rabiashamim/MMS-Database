/****** Object:  Table [dbo].[MtCapacityObligationsDetails]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtCapacityObligationsDetails(
	[MtCapacityObligationsDetails_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtSOFileMaster_Id] [decimal](18, 0) NULL,
	[SrCategory_Code] [varchar](4) NULL,
	[MtCapacityObligationsSettings_Percentage] [decimal](18, 4) NULL,
	[MtCapacityObligationsDetails_Year] [varchar](10) NULL,
	[MtCapacityObligationsDetails_TransmissionLoss] [decimal](24, 8) NULL,
	[MtCapacityObligationsDetails_ReserveMargin] [decimal](24, 8) NULL,
	[MtCapacityObligationsDetails_CreatedBy] [int] NOT NULL,
	[MtCapacityObligationsDetails_CreatedOn] [datetime] NOT NULL,
	[MtCapacityObligationsDetails_ModifiedBy] [int] NULL,
	[MtCapacityObligationsDetails_ModifiedOn] [datetime] NULL,
	[MtCapacityObligationsDetails_IsDeleted] [bit] NULL,
	[MtCapacityObligationsDetails_YearReference] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[MtCapacityObligationsDetails_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.MtCapacityObligationsDetails ADD  DEFAULT ((0)) FOR [MtCapacityObligationsDetails_IsDeleted]
ALTER TABLE dbo.MtCapacityObligationsDetails  WITH CHECK ADD FOREIGN KEY([MtSOFileMaster_Id])
REFERENCES [dbo].[MtSOFileMaster] ([MtSOFileMaster_Id])
ALTER TABLE dbo.MtCapacityObligationsDetails  WITH CHECK ADD FOREIGN KEY([SrCategory_Code])
REFERENCES [dbo].[SrCategory] ([SrCategory_Code])
