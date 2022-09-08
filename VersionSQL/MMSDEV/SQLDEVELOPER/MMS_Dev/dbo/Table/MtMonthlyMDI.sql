/****** Object:  Table [dbo].[MtMonthlyMDI]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MtMonthlyMDI](
	[MtMonthlyMDI_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtMDIImportInfo_Id] [decimal](18, 0) NULL,
	[RuCDPDetail_CdpId] [varchar](100) NULL,
	[MtMonthlyMDI_Month] [int] NULL,
	[MtMonthlyMDI_DateTimeStampImport] [datetime] NULL,
	[MtMonthlyMDI_MdiMonthImport] [decimal](18, 4) NULL,
	[MtMonthlyMDI_MeterIdImport] [decimal](18, 0) NULL,
	[MtMonthlyMDI_DataSourceImport] [varchar](50) NULL,
	[MtMonthlyMDI_MeterQualifierImport] [varchar](100) NULL,
	[MtMonthlyMDI_DataLabelImport] [varchar](100) NULL,
	[MtMonthlyMDI_DataStatusImport] [varchar](100) NULL,
	[MtMonthlyMDI_DateTimeStampExport] [datetime] NULL,
	[MtMonthlyMDI_MdiMonthExport] [decimal](18, 4) NULL,
	[MtMonthlyMDI_MeterIdExport] [decimal](18, 0) NULL,
	[MtMonthlyMDI_DataSourceExport] [varchar](50) NULL,
	[MtMonthlyMDI_MeterQualifierExport] [varchar](100) NULL,
	[MtMonthlyMDI_DataLabelExport] [varchar](100) NULL,
	[MtMonthlyMDI_DataStatusExport] [varchar](100) NULL,
	[MtMonthlyMDI_CreatedBy] [decimal](18, 0) NULL,
	[MtMonthlyMDI_CreatedOn] [datetime] NULL,
	[MtMonthlyMDI_ModifiedBy] [decimal](18, 0) NULL,
	[MtMonthlyMDI_ModifiedOn] [datetime] NULL,
	[MtMonthlyMDI_IsDeleted] [bit] NULL,
	[MtMonthlyMDI_Year] [int] NULL,
 CONSTRAINT [PK_MtMonthlyMDI] PRIMARY KEY CLUSTERED 
(
	[MtMonthlyMDI_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
