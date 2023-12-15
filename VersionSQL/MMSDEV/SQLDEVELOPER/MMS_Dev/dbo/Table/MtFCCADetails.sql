/****** Object:  Table [dbo].[MtFCCADetails]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtFCCADetails(
	[MtFCCADetails_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtContractRegistration_Id] [decimal](18, 0) NOT NULL,
	[MtPartyRegistration_BuyerId] [decimal](18, 0) NOT NULL,
	[MtFCCAGenerator_Id] [decimal](18, 0) NOT NULL,
	[MtFCCADetails_AllocationFactor] [decimal](5, 3) NULL,
	[MtFCCADetails_AssociatedCapacity] [decimal](38, 13) NULL,
	[MtFCCADetails_CreatedBy] [int] NOT NULL,
	[MtFCCADetails_CreatedOn] [datetime] NOT NULL,
	[MtFCCADetails_ModifiedBy] [int] NULL,
	[MtFCCADetails_ModifiedOn] [datetime] NULL,
	[MtFCCADetails_IsDeleted] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[MtFCCADetails_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.MtFCCADetails ADD  DEFAULT ((0)) FOR [MtFCCADetails_IsDeleted]
ALTER TABLE dbo.MtFCCADetails  WITH CHECK ADD FOREIGN KEY([MtContractRegistration_Id])
REFERENCES [dbo].[MtContractRegistration] ([MtContractRegistration_Id])
ALTER TABLE dbo.MtFCCADetails  WITH CHECK ADD FOREIGN KEY([MtFCCAGenerator_Id])
REFERENCES [dbo].[MtFCCAGenerator] ([MtFCCAGenerator_Id])
ALTER TABLE dbo.MtFCCADetails  WITH CHECK ADD FOREIGN KEY([MtPartyRegistration_BuyerId])
REFERENCES [dbo].[MtPartyRegisteration] ([MtPartyRegisteration_Id])
