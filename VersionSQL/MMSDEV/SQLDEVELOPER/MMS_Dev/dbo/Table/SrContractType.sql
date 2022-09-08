/****** Object:  Table [dbo].[SrContractType]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[SrContractType](
	[SrContractType_Id] [int] NOT NULL,
	[SrContractType_Name] [varchar](200) NULL,
	[SrContractType_CreatedBy] [decimal](18, 0) NULL,
	[SrContractType_CreatedOn] [datetime] NULL,
	[SrContractType_ModifiedBy] [decimal](18, 0) NULL,
	[SrContractType_ModifiedOn] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[SrContractType_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
