/****** Object:  Table [dbo].[MtHourlyMeterReading]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MtHourlyMeterReading](
	[MtHourlyMeterReading_Id] [decimal](18, 0) NOT NULL,
	[MtSmsImportInfo_Id] [decimal](18, 0) NOT NULL,
	[MtCDPDetail_Id] [decimal](18, 0) NOT NULL,
	[MtHourlyMeterReading_Date] [date] NOT NULL,
	[MtHourlyMeterReading_Hour] [varchar](5) NOT NULL,
	[MtHourlyMeterReading_BvmImport] [decimal](8, 4) NULL,
	[MtHourlyMeterReading_BvmExport] [decimal](8, 4) NULL,
	[MtHourlyMeterReading_CreatedBy] [decimal](18, 0) NOT NULL,
	[MtHourlyMeterReading_CreatedOn] [datetime] NOT NULL,
	[MtHourlyMeterReading_ModifiedBy] [decimal](18, 0) NULL,
	[MtHourlyMeterReading_ModifiedOn] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[MtHourlyMeterReading_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
