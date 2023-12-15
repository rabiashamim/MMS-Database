/****** Object:  Table [dbo].[Lu_CapUnitGenVari]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.Lu_CapUnitGenVari(
	[Lu_CapUnitGenVari_Id] [int] NOT NULL,
	[Lu_CapUnitGenVari_Name] [nvarchar](100) NULL,
 CONSTRAINT [PK_Lu_CapUnitGenVari] PRIMARY KEY CLUSTERED 
(
	[Lu_CapUnitGenVari_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
