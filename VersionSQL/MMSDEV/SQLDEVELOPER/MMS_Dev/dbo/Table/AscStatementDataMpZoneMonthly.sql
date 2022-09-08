/****** Object:  Table [dbo].[AscStatementDataMpZoneMonthly]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[AscStatementDataMpZoneMonthly](
	[AscStatementData_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[AscStatementData_Year] [int] NOT NULL,
	[AscStatementData_Month] [int] NOT NULL,
	[AscStatementData_CongestedZoneID] [int] NOT NULL,
	[AscStatementData_PartyRegisteration_Id] [decimal](18, 0) NOT NULL,
	[AscStatementData_PartyName] [nvarchar](200) NOT NULL,
	[AscStatementData_PartyType_Code] [varchar](4) NOT NULL,
	[AscStatementData_MRC] [decimal](25, 13) NULL,
	[AscStatementData_RG_AC] [decimal](25, 13) NULL,
	[AscStatementData_IG_AC] [decimal](25, 13) NULL,
	[AscStatementData_SC_BSC] [decimal](25, 13) NULL,
	[AscStatementData_MAC] [decimal](25, 13) NULL,
	[AscStatementData_GS_SC] [decimal](25, 13) NULL,
	[AscStatementData_GBS_BSC] [decimal](25, 13) NULL,
	[AscStatementData_PAYABLE] [decimal](25, 13) NULL,
	[AscStatementData_RECEIVABLE] [decimal](25, 13) NULL,
	[AscStatementData_StatementProcessId] [decimal](18, 0) NOT NULL,
	[AscStatementData_ES] [decimal](25, 13) NULL,
	[AscStatementData_TP_SOLR] [decimal](25, 13) NULL,
	[AscStatementData_CongestedZone] [nvarchar](50) NULL,
	[AscStatementData_TR_SOLR] [decimal](25, 13) NULL,
	[AscStatementData_ET] [decimal](25, 13) NULL,
 CONSTRAINT [PK_AscStatementDataMpZoneMonthly] PRIMARY KEY CLUSTERED 
(
	[AscStatementData_Year] ASC,
	[AscStatementData_Month] ASC,
	[AscStatementData_CongestedZoneID] ASC,
	[AscStatementData_PartyRegisteration_Id] ASC,
	[AscStatementData_StatementProcessId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
