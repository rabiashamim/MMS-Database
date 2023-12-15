/****** Object:  Table [dbo].[EtlHourly]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.EtlHourly(
	[EtlHourly_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtStatementProcess_ID] [decimal](18, 0) NOT NULL,
	[EtlHourly_Year] [int] NOT NULL,
	[EtlHourly_Month] [int] NOT NULL,
	[EtlHourly_Day] [int] NOT NULL,
	[EtlHourly_Hour] [int] NOT NULL,
	[EtlHourly_TranmissionLoss] [decimal](38, 13) NULL,
	[EtlHourly_Demand] [decimal](38, 13) NULL,
	[EtlHourly_MarginalPrice] [decimal](38, 13) NULL,
PRIMARY KEY CLUSTERED 
(
	[MtStatementProcess_ID] ASC,
	[EtlHourly_Year] ASC,
	[EtlHourly_Month] ASC,
	[EtlHourly_Day] ASC,
	[EtlHourly_Hour] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.EtlHourly  WITH CHECK ADD  CONSTRAINT [FK__EtlHourly__MtSta__67001F3A] FOREIGN KEY([MtStatementProcess_ID])
REFERENCES [dbo].[MtStatementProcess] ([MtStatementProcess_ID])
ALTER TABLE dbo.EtlHourly CHECK CONSTRAINT [FK__EtlHourly__MtSta__67001F3A]
