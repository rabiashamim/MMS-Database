/****** Object:  Table [dbo].[Employee]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.Employee(
	[Employee_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[Employee_Name] [varchar](50) NULL,
	[Employee_Rank] [varchar](30) NULL,
	[Employee_CreatedAt] [datetime] NULL,
	[IsDeleted] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[Employee_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.Employee ADD  DEFAULT ((0)) FOR [IsDeleted]
