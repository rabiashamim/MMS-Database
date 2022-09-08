/****** Object:  Table [dbo].[InterfaceMtBvmReading]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[InterfaceMtBvmReading](
	[InterfaceMtBvmReading_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[InterfaceMtBvmReadingIntf_NtdcDateTime] [datetime] NULL,
	[InterfaceRuCDPDetail_CdpId] [varchar](100) NULL,
	[InterfaceRuCdpMeters_MeterIdImport] [decimal](18, 0) NULL,
	[InterfaceMtBvmReading_IncEnergyImport] [decimal](18, 4) NULL,
	[InterfaceMtBvmReading_DataSourceImport] [varchar](50) NULL,
	[InterfaceRuCdpMeters_MeterIdExport] [decimal](18, 0) NULL,
	[InterfaceMtBvmReading_IncEnergyExport] [decimal](18, 4) NULL,
	[InterfaceMtBvmReading_DataSourceExport] [varchar](50) NULL,
	[InterfaceMtBvmReading_CreatedOn] [datetime] NULL,
	[InterfaceMtBvmReading_ModifiedOn] [datetime] NULL,
	[InterfaceMtBvmReading_IsDeleted] [bit] NULL,
	[InterfaceMtBvmReading_MeterQualifierImport] [varchar](100) NULL,
	[InterfaceMtBvmReading_DataLabelImport] [varchar](100) NULL,
	[InterfaceMtBvmReading_DataStatusImport] [varchar](100) NULL,
	[InterfaceMtBvmReading_MeterQualifierExport] [varchar](100) NULL,
	[InterfaceMtBvmReading_DataLabelExport] [varchar](100) NULL,
	[InterfaceMtBvmReading_DataStatusExport] [varchar](100) NULL,
 CONSTRAINT [PK__Interfac__7878780D62DBFBAA] PRIMARY KEY CLUSTERED 
(
	[InterfaceMtBvmReading_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
