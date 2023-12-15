/****** Object:  Table [dbo].[BMCPYSSMPData]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.BMCPYSSMPData(
	[BMCPYSSMPData_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[BMCPYSSMPData_RequiredSecurityCover] [decimal](38, 13) NULL,
	[BMCPYSSMPData_SubmittedSecurityCover] [decimal](38, 13) NULL,
	[BMCPYSSMPData_CapacityAvailableRevised] [decimal](38, 13) NULL,
	[BMCPYSSMPData_PreliminaryCapacityAllocatedSC] [decimal](38, 13) NULL,
	[BMCPYSSMPData_CapacitySoldRevised] [decimal](38, 13) NULL,
	[BMCPYSSMPData_AmountReceivableRevised] [decimal](38, 13) NULL,
	[BMCPYSSMPData_AmountPayableRevised] [decimal](38, 13) NULL,
	[MtPartyRegisteration_Id] [decimal](18, 0) NULL,
	[MtStatementProcess_ID] [decimal](18, 0) NULL,
	[BMCPYSSMPData_CapacityPurchasedRevised] [decimal](38, 13) NULL,
	[BMCPYSSMPData_AddlCapacityAvailableShareReduction] [decimal](38, 13) NULL,
	[BMCPYSSMPData_CapacityAvailableRevisedShare] [decimal](38, 13) NULL,
	[BMCPYSSMPData_ExcessCapacityNotRequired] [decimal](38, 13) NULL,
	[BMCPYSSMPData_ExcessCapacityNotRequiredShare] [decimal](38, 13) NULL
) ON [PRIMARY]

ALTER TABLE dbo.BMCPYSSMPData  WITH CHECK ADD FOREIGN KEY([MtPartyRegisteration_Id])
REFERENCES [dbo].[MtPartyRegisteration] ([MtPartyRegisteration_Id])
ALTER TABLE dbo.BMCPYSSMPData  WITH CHECK ADD FOREIGN KEY([MtStatementProcess_ID])
REFERENCES [dbo].[MtStatementProcess] ([MtStatementProcess_ID])
