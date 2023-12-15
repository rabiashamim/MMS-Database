/****** Object:  Table [dbo].[MtFCCAAssigmentDetails]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtFCCAAssigmentDetails(
	[MtFCCAAssigmentDetails_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtFCCADetails_Id] [decimal](18, 0) NULL,
	[MtFCCAAssigmentDetails_FromCertificate] [varchar](100) NULL,
	[MtFCCAAssigmentDetails_ToCertificate] [varchar](100) NULL,
	[MtFCCAAssigmentDetails_CreatedBy] [int] NOT NULL,
	[MtFCCAAssigmentDetails_CreatedOn] [datetime] NOT NULL,
	[MtFCCAAssigmentDetails_ModifiedBy] [int] NULL,
	[MtFCCAAssigmentDetails_ModifiedOn] [datetime] NULL,
	[MtFCCAAssigmentDetails_IsDeleted] [bit] NOT NULL,
	[MtFCCAAssigmentDetails_IsDisabled] [bit] NULL,
	[MtFCCAAssigmentDetails_OwnerPartyId] [decimal](18, 0) NULL,
	[MtFCCAAssigmentDetails_DisabledDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[MtFCCAAssigmentDetails_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.MtFCCAAssigmentDetails ADD  DEFAULT (getdate()) FOR [MtFCCAAssigmentDetails_CreatedOn]
ALTER TABLE dbo.MtFCCAAssigmentDetails ADD  DEFAULT ((0)) FOR [MtFCCAAssigmentDetails_IsDeleted]
ALTER TABLE dbo.MtFCCAAssigmentDetails ADD  DEFAULT ((0)) FOR [MtFCCAAssigmentDetails_IsDisabled]
ALTER TABLE dbo.MtFCCAAssigmentDetails  WITH CHECK ADD FOREIGN KEY([MtFCCADetails_Id])
REFERENCES [dbo].[MtFCCADetails] ([MtFCCADetails_Id])
ALTER TABLE dbo.MtFCCAAssigmentDetails  WITH CHECK ADD FOREIGN KEY([MtFCCAAssigmentDetails_OwnerPartyId])
REFERENCES [dbo].[MtPartyRegisteration] ([MtPartyRegisteration_Id])
