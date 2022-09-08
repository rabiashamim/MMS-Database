/****** Object:  Table [dbo].[MtGeneratorBS]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MtGeneratorBS](
	[MtGeneratorBS_Id] [decimal](18, 0) NOT NULL,
	[MtSOFileMaster_Id] [decimal](18, 0) NOT NULL,
	[MtGenerationUnit_Id] [decimal](18, 0) NOT NULL,
	[MtGeneratorBS_Date] [date] NOT NULL,
	[MtGeneratorBS_BSCharges] [decimal](20, 4) NOT NULL,
	[MtGeneratorBS_CreatedBy] [int] NOT NULL,
	[MtGeneratorBS_CreatedOn] [datetime] NOT NULL,
	[MtGeneratorBS_ModifiedBy] [int] NULL,
	[MtGeneratorBS_ModifiedOn] [datetime] NULL,
	[MtGeneratorBS_IsDeleted] [bit] NULL,
	[MtGeneratorBS_BSRemarks] [varchar](max) NULL,
 CONSTRAINT [PK_MtGeneratorBS] PRIMARY KEY CLUSTERED 
(
	[MtGeneratorBS_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[MtGeneratorBS]  WITH CHECK ADD FOREIGN KEY([MtSOFileMaster_Id])
REFERENCES [dbo].[MtSOFileMaster] ([MtSOFileMaster_Id])
ALTER TABLE [dbo].[MtGeneratorBS]  WITH CHECK ADD FOREIGN KEY([MtSOFileMaster_Id])
REFERENCES [dbo].[MtSOFileMaster] ([MtSOFileMaster_Id])
