/****** Object:  Table [dbo].[MtGeneratorStart]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MtGeneratorStart](
	[MtGeneratorStart_Id] [decimal](18, 0) NOT NULL,
	[MtSOFileMaster_Id] [decimal](18, 0) NOT NULL,
	[MtGenerationUnit_Id] [decimal](18, 0) NOT NULL,
	[MtGeneratorStart_Date] [date] NOT NULL,
	[MtGeneratorStart_NoOfStarts] [int] NOT NULL,
	[MtGeneratorStart_UnitCost] [decimal](20, 4) NOT NULL,
	[MtGeneratorStart_CostDetermined] [varchar](max) NOT NULL,
	[MtGeneratorStart_CreatedBy] [int] NOT NULL,
	[MtGeneratorStart_CreatedOn] [datetime] NOT NULL,
	[MtGeneratorStart_ModifiedBy] [int] NULL,
	[MtGeneratorStart_ModifiedOn] [datetime] NULL,
	[MtGeneratorStart_IsDeleted] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[MtGeneratorStart_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[MtGeneratorStart]  WITH CHECK ADD FOREIGN KEY([MtSOFileMaster_Id])
REFERENCES [dbo].[MtSOFileMaster] ([MtSOFileMaster_Id])
