/****** Object:  Table [dbo].[EtlTspHourly]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.EtlTspHourly(
	[EtlTspHourly_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtStatementProcess_ID] [decimal](18, 0) NOT NULL,
	[EtlTspHourly_Year] [int] NOT NULL,
	[EtlTspHourly_Month] [int] NOT NULL,
	[EtlTspHourly_Day] [int] NOT NULL,
	[EtlTspHourly_Hour] [int] NOT NULL,
	[MTPartyRegisteration_Id] [decimal](18, 0) NOT NULL,
	[EtlTspHourly_AdjustedEnergyImport] [decimal](38, 13) NULL,
	[EtlTspHourly_AdjustedEnergyExport] [decimal](38, 13) NULL,
	[EtlTspHourly_TransmissionLoss] [decimal](38, 13) NULL,
PRIMARY KEY CLUSTERED 
(
	[MtStatementProcess_ID] ASC,
	[EtlTspHourly_Year] ASC,
	[EtlTspHourly_Month] ASC,
	[EtlTspHourly_Day] ASC,
	[EtlTspHourly_Hour] ASC,
	[MTPartyRegisteration_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.EtlTspHourly  WITH CHECK ADD  CONSTRAINT [FK__EtlTspHou__MtSta__6423B28F] FOREIGN KEY([MtStatementProcess_ID])
REFERENCES [dbo].[MtStatementProcess] ([MtStatementProcess_ID])
ALTER TABLE dbo.EtlTspHourly CHECK CONSTRAINT [FK__EtlTspHou__MtSta__6423B28F]
