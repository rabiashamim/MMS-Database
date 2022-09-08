/****** Object:  Table [dbo].[MtConnectedMeterStationUnit]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MtConnectedMeterStationUnit](
	[MtConnectedMeterStationUnit_Id] [decimal](18, 0) NOT NULL,
	[MtConnectedMeter_Id] [decimal](18, 0) NOT NULL,
	[MtGenerationUnit_Id] [decimal](18, 0) NOT NULL,
	[MtConnectedMeterStationUnit_CreatedBy] [decimal](18, 0) NOT NULL,
	[MtConnectedMeterStationUnit_CreatedOn] [datetime] NOT NULL,
	[MtConnectedMeterStationUnit_ModifiedBy] [decimal](18, 0) NULL,
	[MtConnectedMeterStationUnit_ModifiedOn] [datetime] NULL,
	[MtConnectedMeterStationUnit_Deleted] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[MtConnectedMeterStationUnit_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[MtConnectedMeterStationUnit]  WITH CHECK ADD FOREIGN KEY([MtConnectedMeter_Id])
REFERENCES [dbo].[MtConnectedMeter] ([MtConnectedMeter_Id])
ALTER TABLE [dbo].[MtConnectedMeterStationUnit]  WITH CHECK ADD FOREIGN KEY([MtGenerationUnit_Id])
REFERENCES [dbo].[MtGenerationUnit] ([MtGenerationUnit_Id])
