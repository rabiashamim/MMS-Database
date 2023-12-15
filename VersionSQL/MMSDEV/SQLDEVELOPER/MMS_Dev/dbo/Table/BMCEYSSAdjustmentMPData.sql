/****** Object:  Table [dbo].[BMCEYSSAdjustmentMPData]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.BMCEYSSAdjustmentMPData(
	[BMCEYSSAdjustmentMPData_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtStatementProcess_ID] [decimal](18, 0) NOT NULL,
	[MtPartyRegisteration_Id] [decimal](18, 0) NOT NULL,
	[MtStatementProcess_ID_Reference] [decimal](18, 0) NULL,
	[BMCEYSSAdjustmentMPData_NetAmountPayable] [decimal](38, 13) NULL,
	[BMCEYSSAdjustmentMPData_NetAmountReceivable] [decimal](38, 13) NULL,
	[BMCEYSSAdjustmentMPData_NetAdjustments] [decimal](38, 13) NULL
) ON [PRIMARY]

ALTER TABLE dbo.BMCEYSSAdjustmentMPData  WITH CHECK ADD FOREIGN KEY([MtPartyRegisteration_Id])
REFERENCES [dbo].[MtPartyRegisteration] ([MtPartyRegisteration_Id])
ALTER TABLE dbo.BMCEYSSAdjustmentMPData  WITH CHECK ADD FOREIGN KEY([MtStatementProcess_ID])
REFERENCES [dbo].[MtStatementProcess] ([MtStatementProcess_ID])
ALTER TABLE dbo.BMCEYSSAdjustmentMPData  WITH CHECK ADD FOREIGN KEY([MtStatementProcess_ID_Reference])
REFERENCES [dbo].[MtStatementProcess] ([MtStatementProcess_ID])
