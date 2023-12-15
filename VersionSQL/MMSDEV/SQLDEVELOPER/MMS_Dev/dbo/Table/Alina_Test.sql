/****** Object:  Table [dbo].[Alina_Test]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.Alina_Test(
	[Test_Id] [int] IDENTITY(1,1) NOT NULL,
	[Test_Name] [varchar](100) NULL,
	[Test_Password] [varchar](50) NULL,
	[Test_CreatedOn] [datetime] NOT NULL,
 CONSTRAINT [PK_Alina_Test] PRIMARY KEY CLUSTERED 
(
	[Test_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
