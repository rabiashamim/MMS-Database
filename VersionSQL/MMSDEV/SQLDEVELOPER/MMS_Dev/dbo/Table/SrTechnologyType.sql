/****** Object:  Table [dbo].[SrTechnologyType]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[SrTechnologyType](
	[SrTechnologyType_Code] [varchar](4) NOT NULL,
	[SrTechnologyType_Name] [varchar](50) NOT NULL,
	[SrTechnologyType_CreatedBy] [decimal](18, 0) NULL,
	[SrTechnologyType_CreatedOn] [datetime] NULL,
	[SrTechnologyType_ModifiedBy] [decimal](18, 0) NULL,
	[SrTechnologyType_ModifiedOn] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[SrTechnologyType_Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
