/****** Object:  Table [dbo].[MTDeterminationSecurityCoverSummary]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MTDeterminationSecurityCoverSummary(
	[MTDeterminationSecurityCoverSummary_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtSofileMasterId] [decimal](18, 0) NULL,
	[MTDeterminationSecurityCoverSummary_Seller_SC] [decimal](25, 13) NULL,
	[MTDeterminationSecurityCoverSummary_Seller_SGC] [decimal](25, 13) NULL,
	[MTDeterminationSecurityCoverSummary_Seller_TaxIncSC] [decimal](25, 13) NULL,
	[MTDeterminationSecurityCoverSummary_Seller_SGCTaxInc] [decimal](25, 13) NULL,
	[MTDeterminationSecurityCoverSummary_Buyer_SC] [decimal](25, 13) NULL,
	[MTDeterminationSecurityCoverSummary_Buyer_SGC] [decimal](25, 13) NULL,
	[MTDeterminationSecurityCoverSummary_Buyer_TaxIncSC] [decimal](25, 13) NULL,
	[MTDeterminationSecurityCoverSummary_Buyer_SGCTaxInc] [decimal](25, 13) NULL,
	[MTDeterminationSecurityCoverSummary_CreatedOn] [datetime] NOT NULL,
	[MTDeterminationSecurityCoverSummary_CreatedBy] [int] NOT NULL,
	[MTDeterminationSecurityCoverSummary_ModifiedBy] [int] NULL,
	[MTDeterminationSecurityCoverSummary_ModifiedOn] [datetime] NULL,
	[MTDeterminationSecurityCoverSummary_IsDeleted] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[MTDeterminationSecurityCoverSummary_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.MTDeterminationSecurityCoverSummary ADD  DEFAULT (getdate()) FOR [MTDeterminationSecurityCoverSummary_CreatedOn]
ALTER TABLE dbo.MTDeterminationSecurityCoverSummary ADD  DEFAULT ((0)) FOR [MTDeterminationSecurityCoverSummary_IsDeleted]
ALTER TABLE dbo.MTDeterminationSecurityCoverSummary  WITH CHECK ADD FOREIGN KEY([MtSofileMasterId])
REFERENCES [dbo].[MtSOFileMaster] ([MtSOFileMaster_Id])
