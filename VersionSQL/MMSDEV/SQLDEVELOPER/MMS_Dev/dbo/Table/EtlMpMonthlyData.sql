/****** Object:  Table [dbo].[EtlMpMonthlyData]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.EtlMpMonthlyData(
	[EtlMpMonthlyData_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtStatementProcess_ID] [decimal](18, 0) NOT NULL,
	[MTPartyRegisteration_Id] [decimal](18, 0) NOT NULL,
	[EtlMpMonthlyData_Month] [int] NOT NULL,
	[EtlMpMonthlyData_ActualEnergy] [decimal](38, 13) NULL
) ON [PRIMARY]

ALTER TABLE dbo.EtlMpMonthlyData  WITH CHECK ADD  CONSTRAINT [FK__EtlMpData__MtSta__5F5FD72] FOREIGN KEY([MtStatementProcess_ID])
REFERENCES [dbo].[MtStatementProcess] ([MtStatementProcess_ID])
ALTER TABLE dbo.EtlMpMonthlyData CHECK CONSTRAINT [FK__EtlMpData__MtSta__5F5FD72]
