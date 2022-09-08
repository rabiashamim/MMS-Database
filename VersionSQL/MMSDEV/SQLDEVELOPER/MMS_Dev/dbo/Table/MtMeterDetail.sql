/****** Object:  Table [dbo].[MtMeterDetail]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MtMeterDetail](
	[MtMeterDetail_Id] [decimal](18, 0) NOT NULL,
	[MtMeterDetail_MeterId] [varchar](50) NULL,
	[MtMeterDetail_IsPrimary] [bit] NULL,
	[MtMeterDetail_MeterName] [varchar](50) NULL,
	[MtMeterDetail_StatusCode] [varchar](20) NULL,
	[MtMeterDetail_MeterType] [varchar](20) NULL,
	[MtMeterDetail_CreatedBy] [decimal](18, 0) NOT NULL,
	[MtMeterDetail_CreatedOn] [datetime] NOT NULL,
	[MtMeterDetail_ModifiedBy] [decimal](18, 0) NULL,
	[MtMeterDetail_ModifiedOn] [datetime] NULL,
	[MtMeterDetail_MeterQualifier] [varchar](20) NULL,
	[MtMeterDetail_MeteringDataSource] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[MtMeterDetail_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
