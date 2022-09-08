/****** Object:  Table [dbo].[InterfaceMtMonthlyMDI]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[InterfaceMtMonthlyMDI](
	[InterfaceMtMonthlyMDI_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[RuCDPDetail_CdpId] [varchar](100) NULL,
	[InterfaceMtMonthlyMDI_Month] [int] NULL,
	[InterfaceMtMonthlyMDI_DateTimeStampImport] [datetime] NULL,
	[InterfaceMtMonthlyMDI_MdiMonthImport] [decimal](18, 4) NULL,
	[InterfaceMtMonthlyMDI_MeterIdImport] [decimal](18, 0) NULL,
	[InterfaceMtMonthlyMDI_DataSourceImport] [varchar](50) NULL,
	[InterfaceMtMonthlyMDI_MeterQualifierImport] [varchar](100) NULL,
	[InterfaceMtMonthlyMDI_DataLabelImport] [varchar](100) NULL,
	[InterfaceMtMonthlyMDI_DataStatusImport] [varchar](100) NULL,
	[InterfaceMtMonthlyMDI_DateTimeStampExport] [datetime] NULL,
	[InterfaceMtMonthlyMDI_MdiMonthExport] [decimal](18, 4) NULL,
	[InterfaceMtMonthlyMDI_MeterIdExport] [decimal](18, 0) NULL,
	[InterfaceMtMonthlyMDI_DataSourceExport] [varchar](50) NULL,
	[InterfaceMtMonthlyMDI_MeterQualifierExport] [varchar](100) NULL,
	[InterfaceMtMonthlyMDI_DataLabelExport] [varchar](100) NULL,
	[InterfaceMtMonthlyMDI_DataStatusExport] [varchar](100) NULL,
	[InterfaceMtMonthlyMDI_CreatedOn] [datetime] NULL,
	[InterfaceMtMonthlyMDI_ModifiedOn] [datetime] NULL,
	[InterfaceMtMonthlyMDI_IsDeleted] [bit] NULL,
	[InterfaceMtMonthlyMDI_Year] [int] NULL,
 CONSTRAINT [PK_InterfaceMtMonthlyMDI] PRIMARY KEY CLUSTERED 
(
	[InterfaceMtMonthlyMDI_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
