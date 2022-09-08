/****** Object:  Table [dbo].[MtCongestedZone]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MtCongestedZone](
	[MtCongestedZone_Id] [int] NOT NULL,
	[MtCongestedZone_Name] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[MtCongestedZone_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
