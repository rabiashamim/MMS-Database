/****** Object:  Table [dbo].[MTDeterminationSecurityCover]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MTDeterminationSecurityCover(
	[MTDeterminationSecurityCover_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MTDeterminationSecurityCover_RowNumber] [bigint] NOT NULL,
	[MtSOFileMaster_Id] [decimal](18, 0) NOT NULL,
	[MTDeterminationofSecurityCover_ContractTypeID] [int] NOT NULL,
	[MTDeterminationSecurityCover_BuyerID] [decimal](18, 0) NOT NULL,
	[MTDeterminationSecurityCover_SellerID] [decimal](18, 0) NOT NULL,
	[MTDeterminationSecurityCover_Year] [varchar](15) NULL,
	[MTDeterminationSecurityCover_Month] [varchar](15) NULL,
	[MTDeterminationSecurityCover_DSP] [varchar](250) NULL,
	[MTDeterminationSecurityCover_LineVoltage] [varchar](15) NULL,
	[MTDeterminationSecurityCover_GeneratorDispatchProfileforMonth] [decimal](25, 13) NULL,
	[MTDeterminationSecurityCover_LoadProfileBuyer] [decimal](25, 13) NULL,
	[MTDeterminationSecurityCover_FixedQtyContract] [decimal](25, 13) NULL,
	[MTDeterminationSecurityCover_MonthlyAvgMarginalPrice] [decimal](25, 13) NULL,
	[MTDeterminationSecurityCover_LoadProfileAfterGrossUpT&DLosses] [decimal](25, 13) NULL,
	[MTDeterminationSecurityCover_ExpectedImbalanceMonthlySeller] [decimal](25, 13) NULL,
	[MTDeterminationSecurityCover_ExpectedImbalanceMonthlyBuyer] [decimal](25, 13) NULL,
	[MTDeterminationSecurityCover_ExpectedImbalanceSeller] [decimal](25, 13) NULL,
	[MTDeterminationSecurityCover_ExpectedImbalanceBuyer] [decimal](25, 13) NULL,
	[MTDeterminationSecurityCover_CreatedOn] [datetime] NOT NULL,
	[MTDeterminationSecurityCover_ModifiedBy] [int] NULL,
	[MTDeterminationSecurityCover_ModifiedOn] [datetime] NULL,
	[MTDeterminationSecurityCover_IsDeleted] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[MTDeterminationSecurityCover_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.MTDeterminationSecurityCover ADD  DEFAULT (getdate()) FOR [MTDeterminationSecurityCover_CreatedOn]
ALTER TABLE dbo.MTDeterminationSecurityCover ADD  DEFAULT ((0)) FOR [MTDeterminationSecurityCover_IsDeleted]
ALTER TABLE dbo.MTDeterminationSecurityCover  WITH CHECK ADD FOREIGN KEY([MTDeterminationofSecurityCover_ContractTypeID])
REFERENCES [dbo].[SrContractType] ([SrContractType_Id])
ALTER TABLE dbo.MTDeterminationSecurityCover  WITH CHECK ADD FOREIGN KEY([MTDeterminationSecurityCover_BuyerID])
REFERENCES [dbo].[MtPartyRegisteration] ([MtPartyRegisteration_Id])
ALTER TABLE dbo.MTDeterminationSecurityCover  WITH CHECK ADD FOREIGN KEY([MTDeterminationSecurityCover_SellerID])
REFERENCES [dbo].[MtPartyRegisteration] ([MtPartyRegisteration_Id])
ALTER TABLE dbo.MTDeterminationSecurityCover  WITH CHECK ADD FOREIGN KEY([MtSOFileMaster_Id])
REFERENCES [dbo].[MtSOFileMaster] ([MtSOFileMaster_Id])
