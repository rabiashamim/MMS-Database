/****** Object:  Table [dbo].[tempPreviousMeteringData]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[tempPreviousMeteringData](
	[RuCDPDetail_CdpId] [varchar](100) NULL,
	[MtBvmReading_IncEnergyImport] [decimal](18, 4) NULL,
	[MtBvmReading_IncEnergyExport] [decimal](18, 4) NULL,
	[MtBvmReading_ReadingDate] [date] NULL,
	[MtBvmReading_ReadingHour] [int] NULL
) ON [PRIMARY]
