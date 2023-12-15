/****** Object:  Table [dbo].[Lu_PowerPolicy]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.Lu_PowerPolicy(
	[Lu_PowerPolicy_Id] [int] NOT NULL,
	[Lu_PowerPolicy_Name] [nvarchar](50) NULL,
 CONSTRAINT [PK_Lu_PowerPolicy] PRIMARY KEY CLUSTERED 
(
	[Lu_PowerPolicy_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
