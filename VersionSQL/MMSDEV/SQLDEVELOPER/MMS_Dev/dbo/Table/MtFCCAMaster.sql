/****** Object:  Table [dbo].[MtFCCAMaster]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtFCCAMaster(
	[MtFCCAMaster_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtPartyRegisteration_Id] [decimal](18, 0) NOT NULL,
	[MtFCCAMaster_ApprovalStatus] [varchar](100) NULL,
	[MtFCCAMaster_KEShare] [decimal](25, 13) NULL,
	[MtFCCAMaster_CreatedBy] [int] NOT NULL,
	[MtFCCAMaster_CreatedOn] [datetime] NOT NULL,
	[MtFCCAMaster_ModifiedBy] [int] NULL,
	[MtFCCAMaster_ModifiedOn] [datetime] NULL,
	[MtFCCAMaster_IsDeleted] [bit] NOT NULL,
	[MtFCCAMaster_Status] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[MtFCCAMaster_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.MtFCCAMaster ADD  DEFAULT ((0)) FOR [MtFCCAMaster_IsDeleted]
ALTER TABLE dbo.MtFCCAMaster  WITH CHECK ADD FOREIGN KEY([MtPartyRegisteration_Id])
REFERENCES [dbo].[MtPartyRegisteration] ([MtPartyRegisteration_Id])
