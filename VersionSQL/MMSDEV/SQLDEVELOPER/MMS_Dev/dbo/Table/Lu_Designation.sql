/****** Object:  Table [dbo].[Lu_Designation]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Lu_Designation](
	[Lu_Designation_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[Lu_Designation_Name] [varchar](100) NULL,
 CONSTRAINT [PK_Lu_Designation] PRIMARY KEY CLUSTERED 
(
	[Lu_Designation_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
