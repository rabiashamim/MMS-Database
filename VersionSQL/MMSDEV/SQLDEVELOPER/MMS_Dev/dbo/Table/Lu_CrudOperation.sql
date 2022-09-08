/****** Object:  Table [dbo].[Lu_CrudOperation]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Lu_CrudOperation](
	[Lu_CrudOperation_Id] [int] NOT NULL,
	[Lu_CrudOperation_Name] [varchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[Lu_CrudOperation_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
