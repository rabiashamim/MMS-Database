/****** Object:  Table [dbo].[BmeStatementDataMpMonthly]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[BmeStatementDataMpMonthly](
	[BmeStatementData_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[BmeStatementData_Year] [int] NOT NULL,
	[BmeStatementData_Month] [int] NOT NULL,
	[BmeStatementData_PartyRegisteration_Id] [decimal](18, 0) NOT NULL,
	[BmeStatementData_PartyName] [nvarchar](200) NOT NULL,
	[BmeStatementData_PartyType_Code] [varchar](4) NOT NULL,
	[BmeStatementData_ImbalanceCharges] [decimal](25, 13) NULL,
	[BmeStatementData_SettlementOfLegacy] [decimal](25, 13) NULL,
	[BmeStatementData_AmountPayableReceivable] [decimal](25, 13) NULL,
	[BmeStatementData_EnergySuppliedActual] [decimal](25, 13) NULL,
	[BmeStatementData_IsPowerPool] [bit] NULL,
	[BmeStatementData_StatementProcessId] [decimal](18, 0) NOT NULL,
 CONSTRAINT [PK_BmeStatementDataMpMonthly] PRIMARY KEY CLUSTERED 
(
	[BmeStatementData_Year] ASC,
	[BmeStatementData_Month] ASC,
	[BmeStatementData_PartyRegisteration_Id] ASC,
	[BmeStatementData_StatementProcessId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
