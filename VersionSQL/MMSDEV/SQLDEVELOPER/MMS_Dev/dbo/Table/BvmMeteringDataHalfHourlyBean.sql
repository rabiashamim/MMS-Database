/****** Object:  Table [dbo].[BvmMeteringDataHalfHourlyBean]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[BvmMeteringDataHalfHourlyBean](
	[dateTimeStamp] [varchar](200) NULL,
	[cdpId] [varchar](200) NULL,
	[incrementalActiveEnergyImport] [varchar](200) NULL,
	[iMeterId] [varchar](200) NULL,
	[iMeterQualifier] [varchar](200) NULL,
	[iMeterDataSource] [varchar](200) NULL,
	[iDataStatus] [varchar](200) NULL,
	[iLabel] [varchar](200) NULL,
	[incrementalActiveEnergyExport] [varchar](200) NULL,
	[eMeterId] [varchar](200) NULL,
	[eMeterQualifier] [varchar](200) NULL,
	[eMeterDataSource] [varchar](200) NULL,
	[eDataStatus] [varchar](200) NULL,
	[eLabel] [varchar](200) NULL
) ON [PRIMARY]
