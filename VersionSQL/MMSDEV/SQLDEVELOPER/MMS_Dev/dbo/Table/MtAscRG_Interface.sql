/****** Object:  Table [dbo].[MtAscRG_Interface]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MtAscRG_Interface](
	[MtAscRG_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtSOFileMaster_Id] [decimal](18, 0) NOT NULL,
	[MtGenerationUnit_Id] [nvarchar](max) NULL,
	[MtAscRG_Date] [varchar](max) NULL,
	[MtAscRG_Hour] [varchar](max) NULL,
	[MtAscRG_ExpectedEnergy] [varchar](max) NULL,
	[MtAscRG_VariableCost] [varchar](max) NULL,
	[MtAscRG_CreatedBy] [int] NOT NULL,
	[MtAscRG_CreatedOn] [datetime] NOT NULL,
	[MtAscRG_ModifiedBy] [int] NULL,
	[MtAscRG_ModifiedOn] [datetime] NULL,
	[MtAscRG_IsDeleted] [bit] NULL,
	[GenerationUnitTypeARE] [varchar](max) NULL,
	[MTAscRG_NtdcDateTime] [datetime] NULL,
	[MtAscRG_RowNumber] [bigint] NULL,
	[MtAscRG_IsValid] [bit] NULL,
	[MtAscRG_Message] [nvarchar](max) NULL,
 CONSTRAINT [PK__MtAscRG__2EAAAD9CB1AA900B_interface] PRIMARY KEY CLUSTERED 
(
	[MtAscRG_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
