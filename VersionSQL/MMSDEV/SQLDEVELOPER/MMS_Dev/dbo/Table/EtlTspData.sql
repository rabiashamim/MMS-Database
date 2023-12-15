/****** Object:  Table [dbo].[EtlTspData]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.EtlTspData(
	[EtlTspData_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtStatementProcess_ID] [decimal](18, 0) NOT NULL,
	[MTPartyRegisteration_Id] [decimal](18, 0) NOT NULL,
	[EtlTspData_TransmissionLoss] [decimal](38, 13) NULL,
	[EtlTspData_TotalEnergyInjected] [decimal](38, 13) NULL,
	[EtlTspData_TotalEnergyWithdrawal] [decimal](38, 13) NULL,
	[EtlTspData_AnnualLosses] [decimal](38, 13) NULL,
	[EtlTspData_AllowedCap] [decimal](7, 4) NULL,
	[EtlTspData_AllowableLosses] [decimal](38, 13) NULL,
	[EtlTspData_ExcessLosses] [decimal](38, 13) NULL,
	[EtlTspData_WeightedAverageMarginalPrice] [decimal](38, 13) NULL,
	[EtlTspData_TotalPayableExcessLosses] [decimal](38, 13) NULL,
 CONSTRAINT [PK__EtlTspDa__21C01CD32F9E40CE] PRIMARY KEY CLUSTERED 
(
	[EtlTspData_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
