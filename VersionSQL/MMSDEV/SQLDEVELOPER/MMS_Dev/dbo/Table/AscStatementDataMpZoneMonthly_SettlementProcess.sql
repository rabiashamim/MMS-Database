﻿/****** Object:  Table [dbo].[AscStatementDataMpZoneMonthly_SettlementProcess]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.AscStatementDataMpZoneMonthly_SettlementProcess(
	[AscStatementData_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[AscStatementData_Year] [int] NOT NULL,
	[AscStatementData_Month] [int] NOT NULL,
	[AscStatementData_CongestedZoneID] [int] NULL,
	[AscStatementData_PartyRegisteration_Id] [decimal](18, 0) NULL,
	[AscStatementData_PartyName] [nvarchar](200) NULL,
	[AscStatementData_PartyType_Code] [varchar](4) NULL,
	[AscStatementData_MRC] [decimal](25, 13) NULL,
	[AscStatementData_RG_AC] [decimal](25, 13) NULL,
	[AscStatementData_IG_AC] [decimal](25, 13) NULL,
	[AscStatementData_SC_BSC] [decimal](25, 13) NULL,
	[AscStatementData_MAC] [decimal](25, 13) NULL,
	[AscStatementData_GS_SC] [decimal](25, 13) NULL,
	[AscStatementData_GBS_BSC] [decimal](25, 13) NULL,
	[AscStatementData_PAYABLE] [decimal](25, 13) NULL,
	[AscStatementData_RECEIVABLE] [decimal](25, 13) NULL,
	[AscStatementData_StatementProcessId] [decimal](18, 0) NULL,
	[AscStatementData_SettlementProcessId] [decimal](18, 0) NULL,
	[AscStatementData_ES] [decimal](25, 13) NULL,
	[AscStatementData_TP_SOLR] [decimal](25, 13) NULL,
	[AscStatementData_CongestedZone] [nvarchar](50) NULL,
	[AscStatementData_TR_SOLR] [decimal](25, 13) NULL,
	[AscStatementData_ET] [decimal](25, 13) NULL,
	[AscStatementData_SOLR_ETB_Legacy] [decimal](25, 13) NULL,
	[AscStatementData_LegacyShareInReceiveable] [decimal](25, 13) NULL
) ON [PRIMARY]
