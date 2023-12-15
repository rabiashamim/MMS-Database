/****** Object:  Table [dbo].[BMCVariablesData]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.BMCVariablesData(
	[BMCVariablesData_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[BMCVariablesData_ReserveMargin] [decimal](18, 8) NULL,
	[BMCVariablesData_EfficientlevelReserve] [decimal](18, 8) NULL,
	[BMCVariablesData_UnitaryCostCapacity] [decimal](18, 8) NULL,
	[BMCVariablesData_KEShare_MW] [decimal](18, 8) NULL,
	[BMCVariablesData_CapacityBalanceNegativeSum] [decimal](38, 13) NULL,
	[BMCVariablesData_CapacityBalancePositiveSum] [decimal](38, 13) NULL,
	[BMCVariablesData_EfficientDemandLevel_EDL] [decimal](38, 13) NULL,
	[BMCVariablesData_Slope] [decimal](38, 13) NULL,
	[BMCVariablesData_C_Constant] [decimal](38, 13) NULL,
	[BMCVariablesData_Point_D_Qty] [decimal](38, 13) NULL,
	[BMCVariablesData_CapacityPrice] [decimal](38, 13) NULL,
	[MtStatementProcess_ID] [decimal](18, 0) NULL,
PRIMARY KEY CLUSTERED 
(
	[BMCVariablesData_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.BMCVariablesData  WITH CHECK ADD FOREIGN KEY([MtStatementProcess_ID])
REFERENCES [dbo].[MtStatementProcess] ([MtStatementProcess_ID])
