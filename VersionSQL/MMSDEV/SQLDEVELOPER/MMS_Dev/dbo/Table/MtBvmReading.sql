/****** Object:  Table [dbo].[MtBvmReading]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MtBvmReading](
	[MtBvmReading_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtMeteringImportInfo_Id] [decimal](18, 0) NULL,
	[MtBvmReadingIntf_NtdcDateTime] [datetime] NULL,
	[RuCDPDetail_CdpId] [varchar](100) NULL,
	[RuCdpMeters_MeterIdImport] [decimal](18, 0) NULL,
	[MtBvmReading_IncEnergyImport] [decimal](18, 4) NULL,
	[MtBvmReading_DataSourceImport] [varchar](50) NULL,
	[RuCdpMeters_MeterIdExport] [decimal](18, 0) NULL,
	[MtBvmReading_IncEnergyExport] [decimal](18, 4) NULL,
	[MtBvmReading_DataSourceExport] [varchar](50) NULL,
	[MtBvmReading_CreatedBy] [decimal](18, 0) NULL,
	[MtBvmReading_CreatedOn] [datetime] NULL,
	[MtBvmReading_ModifiedBy] [decimal](18, 0) NULL,
	[MtBvmReading_ModifiedOn] [datetime] NULL,
	[MtBvmReading_ReadingDate] [date] NULL,
	[MtBvmReading_ReadingHour] [int] NULL,
	[IsAlreadyUsedInBME] [bit] NULL,
	[MtBvmReading_MeterQualifierImport] [nvarchar](100) NULL,
	[MtBvmReading_MeterQualifierExport] [nvarchar](100) NULL,
	[ProcessedModifiedImport] [decimal](24, 18) NULL,
	[ProcessedModifiedExport] [decimal](24, 18) NULL,
 CONSTRAINT [PK__MtBvmRea__D1E3F8A99941A9FC] PRIMARY KEY CLUSTERED 
(
	[MtBvmReading_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
