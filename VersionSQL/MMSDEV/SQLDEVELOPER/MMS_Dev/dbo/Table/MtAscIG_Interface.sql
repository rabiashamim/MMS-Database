/****** Object:  Table [dbo].[MtAscIG_Interface]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MtAscIG_Interface](
	[MtAscIG_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtSOFileMaster_Id] [decimal](18, 0) NOT NULL,
	[MtGenerationUnit_Id] [nvarchar](max) NULL,
	[MtAscIG_Date] [varchar](max) NULL,
	[MtAscIG_Hour] [varchar](max) NULL,
	[MtAscIG_VariableCost] [varchar](max) NULL,
	[MtAscIG_CreatedBy] [int] NULL,
	[MtAscIG_CreatedOn] [datetime] NULL,
	[MtAscIG_ModifiedBy] [int] NULL,
	[MtAscIG_ModifiedOn] [datetime] NULL,
	[MtAscIG_IsDeleted] [bit] NULL,
	[EnergyProduceIfNoAncillaryServices] [varchar](max) NULL,
	[Reason] [varchar](max) NULL,
	[MTAscIG_NtdcDateTime] [datetime] NULL,
	[MtAscIG_RowNumber] [bigint] NULL,
	[MtAscIG_IsValid] [bit] NULL,
	[MtAscIG_Message] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[MtAscIG_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
