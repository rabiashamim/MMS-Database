/****** Object:  Table [dbo].[MtAscIG]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MtAscIG](
	[MtAscIG_Id] [decimal](18, 0) NOT NULL,
	[MtSOFileMaster_Id] [decimal](18, 0) NOT NULL,
	[MtGenerationUnit_Id] [decimal](18, 0) NOT NULL,
	[MtAscIG_Date] [date] NOT NULL,
	[MtAscIG_Hour] [varchar](5) NOT NULL,
	[MtAscIG_VariableCost] [decimal](20, 4) NOT NULL,
	[MtAscIG_CreatedBy] [int] NOT NULL,
	[MtAscIG_CreatedOn] [datetime] NOT NULL,
	[MtAscIG_ModifiedBy] [int] NULL,
	[MtAscIG_ModifiedOn] [datetime] NULL,
	[MtAscIG_IsDeleted] [bit] NULL,
	[EnergyProduceIfNoAncillaryServices] [varchar](50) NULL,
	[Reason] [varchar](max) NULL,
	[MTAscIG_NtdcDateTime] [datetime] NULL,
	[MtAscIG_RowNumber] [bigint] NULL,
PRIMARY KEY CLUSTERED 
(
	[MtAscIG_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[MtAscIG]  WITH CHECK ADD FOREIGN KEY([MtSOFileMaster_Id])
REFERENCES [dbo].[MtSOFileMaster] ([MtSOFileMaster_Id])
ALTER TABLE [dbo].[MtAscIG]  WITH CHECK ADD FOREIGN KEY([MtSOFileMaster_Id])
REFERENCES [dbo].[MtSOFileMaster] ([MtSOFileMaster_Id])
