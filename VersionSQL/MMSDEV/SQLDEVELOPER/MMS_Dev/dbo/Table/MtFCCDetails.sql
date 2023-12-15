/****** Object:  Table [dbo].[MtFCCDetails]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtFCCDetails(
	[MtFCCDetails_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtFCCMaster_Id] [decimal](18, 0) NOT NULL,
	[MtFCCDetails_CertificateId] [varchar](100) NOT NULL,
	[MtFCCDetails_Status] [bit] NOT NULL,
	[MtFCCDetails_IsCancelled] [bit] NOT NULL,
	[MtFCCDetails_CreatedBy] [int] NOT NULL,
	[MtFCCDetails_CreatedOn] [date] NOT NULL,
	[MtFCCDetails_ModifiedBy] [int] NULL,
	[MtFCCDetails_ModifiedOn] [date] NULL,
	[MtFCCDetails_IsDeleted] [bit] NOT NULL,
	[MtFCCDetails_ToBeCanceledFlag] [int] NULL,
	[MtFCCDetails_ToBeCanceledDate] [datetime] NULL,
	[MtFCCDetails_OwnerPartyId] [decimal](18, 0) NULL,
PRIMARY KEY CLUSTERED 
(
	[MtFCCDetails_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.MtFCCDetails ADD  CONSTRAINT [DF_MtFCCDetails_MtFCCDetails_IsDeleted]  DEFAULT ((0)) FOR [MtFCCDetails_IsDeleted]
ALTER TABLE dbo.MtFCCDetails  WITH CHECK ADD FOREIGN KEY([MtFCCDetails_OwnerPartyId])
REFERENCES [dbo].[MtPartyRegisteration] ([MtPartyRegisteration_Id])
ALTER TABLE dbo.MtFCCDetails  WITH CHECK ADD FOREIGN KEY([MtFCCMaster_Id])
REFERENCES [dbo].[MtFCCMaster] ([MtFCCMaster_Id])
