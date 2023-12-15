/****** Object:  Table [dbo].[BMCMPGenCreditedCapacity]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.BMCMPGenCreditedCapacity(
	[BMCMPGenCreditedCapacity_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[BMCMPGenCreditedCapacity_CreditedCapacity] [decimal](38, 13) NULL,
	[MtGenerator_Id] [decimal](18, 0) NOT NULL,
	[MtPartyRegisteration_Id] [decimal](18, 0) NOT NULL,
	[MtStatementProcess_ID] [decimal](18, 0) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[BMCMPGenCreditedCapacity_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.BMCMPGenCreditedCapacity  WITH CHECK ADD FOREIGN KEY([MtGenerator_Id])
REFERENCES [dbo].[MtGenerator] ([MtGenerator_Id])
ALTER TABLE dbo.BMCMPGenCreditedCapacity  WITH CHECK ADD FOREIGN KEY([MtPartyRegisteration_Id])
REFERENCES [dbo].[MtPartyRegisteration] ([MtPartyRegisteration_Id])
ALTER TABLE dbo.BMCMPGenCreditedCapacity  WITH CHECK ADD FOREIGN KEY([MtStatementProcess_ID])
REFERENCES [dbo].[MtStatementProcess] ([MtStatementProcess_ID])
