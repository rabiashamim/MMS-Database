/****** Object:  Table [dbo].[BmeStatementData]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[BmeStatementData](
	[BmeStatementData_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[BmeStatementData_NtdcDateTime] [datetime] NULL,
	[BmeStatementData_Year] [int] NOT NULL,
	[BmeStatementData_Month] [int] NOT NULL,
	[BmeStatementData_Day] [int] NOT NULL,
	[BmeStatementData_Hour] [int] NOT NULL,
	[BmeStatementData_CdpId] [varchar](100) NULL,
	[BmeStatementData_MeterIdImport] [decimal](18, 0) NULL,
	[BmeStatementData_IncEnergyImport] [decimal](32, 16) NOT NULL,
	[BmeStatementData_DataSourceImport] [varchar](50) NOT NULL,
	[BmeStatementData_MeterIdExport] [decimal](18, 0) NULL,
	[BmeStatementData_IncEnergyExport] [decimal](32, 16) NOT NULL,
	[BmeStatementData_DataSourceExport] [varchar](50) NOT NULL,
	[BmeStatementData_CreatedBy] [decimal](18, 0) NOT NULL,
	[BmeStatementData_CreatedOn] [datetime] NOT NULL,
	[BmeStatementData_ModifiedBy] [decimal](18, 0) NULL,
	[BmeStatementData_ModifiedOn] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[BmeStatementData_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
