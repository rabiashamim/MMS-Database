﻿/****** Object:  Table [dbo].[AscStatementDataZoneMonthly]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[AscStatementDataZoneMonthly](
	[AscStatementData_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[AscStatementData_Year] [int] NOT NULL,
	[AscStatementData_Month] [int] NOT NULL,
	[AscStatementData_Congestion_Zone] [nvarchar](50) NULL,
	[AscStatementData_SO_MP] [decimal](25, 13) NULL,
	[AscStatementData_SO_AC] [decimal](25, 13) NULL,
	[AscStatementData_SO_AC_ASC] [decimal](25, 13) NULL,
	[AscStatementData_SO_MR_EP] [decimal](25, 13) NULL,
	[AscStatementData_SO_MR_VC] [decimal](25, 13) NULL,
	[AscStatementData_SO_RG_VC] [decimal](25, 13) NULL,
	[AscStatementData_SO_RG_EG_ARE] [decimal](25, 13) NULL,
	[AscStatementData_SO_IG_VC] [decimal](25, 13) NULL,
	[AscStatementData_SO_IG_EPG] [decimal](25, 13) NULL,
	[AscStatementData_MR_EAG] [decimal](25, 13) NULL,
	[AscStatementData_MR_EPG] [decimal](25, 13) NULL,
	[AscStatementData_MRC] [decimal](25, 13) NULL,
	[AscStatementData_RG_EAG] [decimal](25, 13) NULL,
	[AscStatementData_AC_MOD] [decimal](25, 13) NULL,
	[AscStatementData_RG_LOCC] [decimal](25, 13) NULL,
	[AscStatementData_IG_EAG] [decimal](25, 13) NULL,
	[AscStatementData_IG_EPG] [decimal](25, 13) NULL,
	[AscStatementData_IG_UPC] [decimal](25, 13) NULL,
	[AscStatementData_AC_Total] [decimal](25, 13) NULL,
	[AscStatementData_TaxZoneID] [int] NULL,
	[AscStatementData_CongestedZoneID] [int] NOT NULL,
	[AscStatementData_SC_BSC] [decimal](25, 13) NULL,
	[AscStatementData_MAC] [decimal](25, 13) NULL,
	[AscStatementData_TAC] [decimal](25, 13) NULL,
	[AscStatementData_TD] [decimal](25, 13) NULL,
	[AscStatementData_GS_SC] [decimal](25, 13) NULL,
	[AscStatementData_GBS_BSC] [decimal](25, 13) NULL,
	[AscStatementData_RG_AC] [decimal](25, 13) NULL,
	[AscStatementData_IG_AC] [decimal](25, 13) NULL,
	[AscStatementData_StatementProcessId] [decimal](18, 0) NOT NULL,
	[AscStatementData_TP] [decimal](25, 13) NULL,
	[AscStatementData_ES_BS] [decimal](25, 13) NULL,
	[AscStatementData_KE_ES] [decimal](25, 13) NULL,
	[AscStatementData_CongestedZone] [nvarchar](50) NULL,
	[AscStatementData_TR] [decimal](25, 13) NULL,
	[AscStatementData_KE_EB] [decimal](25, 13) NULL,
 CONSTRAINT [PK_AscStatementDataZoneMonthly] PRIMARY KEY CLUSTERED 
(
	[AscStatementData_Year] ASC,
	[AscStatementData_Month] ASC,
	[AscStatementData_CongestedZoneID] ASC,
	[AscStatementData_StatementProcessId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
