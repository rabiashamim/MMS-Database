/****** Object:  Table [dbo].[BmeStatementDataTspHourly]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[BmeStatementDataTspHourly](
	[BmeStatementData_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[BmeStatementData_NtdcDateTime] [datetime] NOT NULL,
	[BmeStatementData_Year] [int] NOT NULL,
	[BmeStatementData_Month] [int] NOT NULL,
	[BmeStatementData_Day] [int] NOT NULL,
	[BmeStatementData_Hour] [int] NOT NULL,
	[BmeStatementData_PartyRegisteration_Id] [decimal](18, 0) NOT NULL,
	[BmeStatementData_PartyName] [nvarchar](200) NOT NULL,
	[BmeStatementData_PartyCategory_Code] [varchar](4) NOT NULL,
	[BmeStatementData_PartyType_Code] [varchar](4) NOT NULL,
	[BmeStatementData_AdjustedEnergyImport] [decimal](25, 13) NULL,
	[BmeStatementData_AdjustedEnergyExport] [decimal](25, 13) NULL,
	[BmeStatementData_TransmissionLosses] [decimal](25, 13) NULL,
	[BmeStatementData_StatementProcessId] [decimal](18, 0) NOT NULL,
 CONSTRAINT [PK_BmeStatementDataTspHourly] PRIMARY KEY CLUSTERED 
(
	[BmeStatementData_NtdcDateTime] ASC,
	[BmeStatementData_PartyRegisteration_Id] ASC,
	[BmeStatementData_StatementProcessId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
