/****** Object:  Table [dbo].[EtlMpData]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.EtlMpData(
	[EtlMpData_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtStatementProcess_ID] [decimal](18, 0) NOT NULL,
	[MTPartyRegisteration_Id] [decimal](18, 0) NOT NULL,
	[EtlMpData_ActualEnergy] [decimal](38, 13) NULL,
	[EtlMpData_ExcessLossesCompensation] [decimal](38, 13) NULL,
	[EtlMpData_ContractedEnergy] [decimal](38, 13) NULL,
	[EtlMpData_AdditionalCompensation] [decimal](38, 13) NULL,
	[EtlMpData_TotalExcessLossesCompensation] [decimal](38, 13) NULL,
 CONSTRAINT [PK__EtlMpDat__FF1AE2F5DC5DD9CE] PRIMARY KEY CLUSTERED 
(
	[EtlMpData_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.EtlMpData  WITH CHECK ADD  CONSTRAINT [FK__EtlMpData__MtSta__5F5EFD72] FOREIGN KEY([MtStatementProcess_ID])
REFERENCES [dbo].[MtStatementProcess] ([MtStatementProcess_ID])
ALTER TABLE dbo.EtlMpData CHECK CONSTRAINT [FK__EtlMpData__MtSta__5F5EFD72]
