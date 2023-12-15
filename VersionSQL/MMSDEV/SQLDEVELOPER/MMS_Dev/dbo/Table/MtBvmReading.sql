/****** Object:  Table [dbo].[MtBvmReading]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtBvmReading(
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
	[MtBvmReading_MeterQualifierImport] [nvarchar](100) NULL,
	[MtBvmReading_MeterQualifierExport] [nvarchar](100) NULL,
	[ProcessedModifiedImport] [decimal](24, 18) NULL,
	[ProcessedModifiedExport] [decimal](24, 18) NULL,
	[IsAlreadyUsedInBME] [int] NULL,
 CONSTRAINT [PK__MtBvmRea__D1E3F8A99941A9FC] PRIMARY KEY CLUSTERED 
(
	[MtBvmReading_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [MTBR_COMP_COL13_index_5] ON dbo.MtBvmReading
(
	[MtBvmReading_IncEnergyImport] ASC,
	[MtBvmReading_IncEnergyExport] ASC
)
INCLUDE([MtMeteringImportInfo_Id],[MtBvmReadingIntf_NtdcDateTime],[RuCDPDetail_CdpId],[RuCdpMeters_MeterIdImport],[MtBvmReading_DataSourceImport],[RuCdpMeters_MeterIdExport],[MtBvmReading_DataSourceExport],[MtBvmReading_CreatedBy],[MtBvmReading_CreatedOn],[MtBvmReading_ModifiedBy],[MtBvmReading_ModifiedOn],[MtBvmReading_ReadingDate],[MtBvmReading_ReadingHour],[IsAlreadyUsedInBME],[MtBvmReading_MeterQualifierImport],[MtBvmReading_MeterQualifierExport]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
ALTER INDEX [MTBR_COMP_COL13_index_5] ON dbo.MtBvmReading DISABLE
