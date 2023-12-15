/****** Object:  Table [dbo].[BMCMPData]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.BMCMPData(
	[BMCMPData_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[BMCMPData_AllocatedCapacity] [decimal](38, 13) NULL,
	[BMCMPData_CapacityRequirement] [decimal](38, 13) NULL,
	[BMCMPData_CapacityBalance] [decimal](38, 13) NULL,
	[BMCMPData_CapacityPurchased] [decimal](38, 13) NULL,
	[BMCMPData_CapacitySold] [decimal](38, 13) NULL,
	[BMCMPData_AmountReceivable] [decimal](38, 13) NULL,
	[BMCMPData_AmountPayable] [decimal](38, 13) NULL,
	[MtPartyRegisteration_Id] [decimal](18, 0) NULL,
	[MtStatementProcess_ID] [decimal](18, 0) NULL,
	[BMCMPData_Actual_E] [decimal](38, 13) NULL,
PRIMARY KEY CLUSTERED 
(
	[BMCMPData_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.BMCMPData  WITH CHECK ADD FOREIGN KEY([MtPartyRegisteration_Id])
REFERENCES [dbo].[MtPartyRegisteration] ([MtPartyRegisteration_Id])
ALTER TABLE dbo.BMCMPData  WITH CHECK ADD FOREIGN KEY([MtStatementProcess_ID])
REFERENCES [dbo].[MtStatementProcess] ([MtStatementProcess_ID])
