/****** Object:  Table [dbo].[MtAscRG]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MtAscRG](
	[MtAscRG_Id] [decimal](18, 0) NOT NULL,
	[MtSOFileMaster_Id] [decimal](18, 0) NOT NULL,
	[MtGenerationUnit_Id] [decimal](18, 0) NOT NULL,
	[MtAscRG_Date] [date] NOT NULL,
	[MtAscRG_Hour] [varchar](5) NOT NULL,
	[MtAscRG_ExpectedEnergy] [decimal](20, 4) NOT NULL,
	[MtAscRG_VariableCost] [decimal](20, 4) NOT NULL,
	[MtAscRG_CreatedBy] [int] NOT NULL,
	[MtAscRG_CreatedOn] [datetime] NOT NULL,
	[MtAscRG_ModifiedBy] [int] NULL,
	[MtAscRG_ModifiedOn] [datetime] NULL,
	[MtAscRG_IsDeleted] [bit] NULL,
	[GenerationUnitTypeARE] [varchar](50) NULL,
	[MTAscRG_NtdcDateTime] [datetime] NULL,
	[MtAscRG_RowNumber] [bigint] NULL,
 CONSTRAINT [PK__MtAscRG__2EAAAD9CB1AA900B] PRIMARY KEY CLUSTERED 
(
	[MtAscRG_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[MtAscRG]  WITH CHECK ADD  CONSTRAINT [FK__MtAscRG__MtSOFil__6442E2C9] FOREIGN KEY([MtSOFileMaster_Id])
REFERENCES [dbo].[MtSOFileMaster] ([MtSOFileMaster_Id])
ALTER TABLE [dbo].[MtAscRG] CHECK CONSTRAINT [FK__MtAscRG__MtSOFil__6442E2C9]
