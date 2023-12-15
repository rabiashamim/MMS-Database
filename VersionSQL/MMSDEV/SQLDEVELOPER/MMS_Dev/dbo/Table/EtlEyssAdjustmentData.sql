/****** Object:  Table [dbo].[EtlEyssAdjustmentData]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.EtlEyssAdjustmentData(
	[EtlEyssAdjustmentData_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtStatementProcess_ID] [decimal](18, 0) NOT NULL,
	[MTPartyRegisteration_Id] [decimal](18, 0) NOT NULL,
	[EtlEyssAdjustmentData_TotalPayableExcessLosses] [decimal](38, 13) NULL,
	[EtlEyssAdjustmentData_TotalExcessLossesCompensation] [decimal](38, 13) NULL,
	[EtlEyssAdjustmentData_NetAdjustments] [decimal](38, 13) NULL,
	[MtStatementProcess_ID_Reference] [decimal](18, 0) NULL,
 CONSTRAINT [PK__EtlEyssAdjustmentData__FF1AE2F5DC5DD9CE] PRIMARY KEY CLUSTERED 
(
	[EtlEyssAdjustmentData_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.EtlEyssAdjustmentData  WITH CHECK ADD  CONSTRAINT [FK__EtlEyssAdjustmentData__MtSta__5F5EFD72] FOREIGN KEY([MtStatementProcess_ID])
REFERENCES [dbo].[MtStatementProcess] ([MtStatementProcess_ID])
ALTER TABLE dbo.EtlEyssAdjustmentData CHECK CONSTRAINT [FK__EtlEyssAdjustmentData__MtSta__5F5EFD72]
