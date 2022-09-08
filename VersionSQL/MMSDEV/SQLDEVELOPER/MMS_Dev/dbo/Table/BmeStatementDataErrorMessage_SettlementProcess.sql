/****** Object:  Table [dbo].[BmeStatementDataErrorMessage_SettlementProcess]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[BmeStatementDataErrorMessage_SettlementProcess](
	[BmeStatementData_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[BmeStatementData_Year] [int] NOT NULL,
	[BmeStatementData_Month] [int] NOT NULL,
	[BmeStatementData_ERROR_NUMBER] [int] NULL,
	[BmeStatementData_ERROR_STATE] [nvarchar](200) NULL,
	[BmeStatementData_ERROR_SEVERITY] [nvarchar](200) NULL,
	[BmeStatementData_ERROR_LINE] [int] NULL,
	[BmeStatementData_ERROR_PROCEDURE] [nvarchar](200) NULL,
	[BmeStatementData_ERROR_MESSAGE] [nvarchar](max) NULL,
	[BmeStatementData_ERROR_TIME] [datetime] NULL,
	[BmeStatementData_SettlementProcessId] [decimal](18, 0) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
