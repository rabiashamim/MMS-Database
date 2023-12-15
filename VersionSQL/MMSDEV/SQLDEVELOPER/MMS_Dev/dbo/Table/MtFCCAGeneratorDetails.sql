/****** Object:  Table [dbo].[MtFCCAGeneratorDetails]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtFCCAGeneratorDetails(
	[MtFCCAGeneratorDetails_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtFCCAGenerator_Id] [decimal](18, 0) NOT NULL,
	[MtFCCAGeneratorDetails_FromCertificate] [varchar](100) NULL,
	[MtFCCAGeneratorDetails_ToCertificate] [varchar](100) NULL,
	[MtFCCAGeneratorDetails_RangeCapacity] [decimal](25, 13) NULL,
	[MtFCCAGeneratorDetails_RangeTotalCertificates] [decimal](18, 0) NULL,
	[MtFCCAGeneratorDetails_IsCancelled] [bit] NULL,
	[MtFCCAGeneratorDetails_CancelledDate] [datetime] NULL,
	[MtFCCAGeneratorDetails_CreatedOn] [datetime] NULL,
	[MtFCCAGeneratorDetails_CreatedBy] [int] NOT NULL,
	[MtFCCAGeneratorDetails_ModifiedOn] [datetime] NULL,
	[MtFCCAGeneratorDetails_ModifiedBy] [int] NULL,
	[MtFCCAGeneratorDetails_Isdeleted] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[MtFCCAGeneratorDetails_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.MtFCCAGeneratorDetails ADD  DEFAULT ((0)) FOR [MtFCCAGeneratorDetails_IsCancelled]
ALTER TABLE dbo.MtFCCAGeneratorDetails ADD  DEFAULT (getdate()) FOR [MtFCCAGeneratorDetails_CreatedOn]
ALTER TABLE dbo.MtFCCAGeneratorDetails ADD  DEFAULT ((0)) FOR [MtFCCAGeneratorDetails_Isdeleted]
ALTER TABLE dbo.MtFCCAGeneratorDetails  WITH CHECK ADD FOREIGN KEY([MtFCCAGenerator_Id])
REFERENCES [dbo].[MtFCCAGenerator] ([MtFCCAGenerator_Id])
