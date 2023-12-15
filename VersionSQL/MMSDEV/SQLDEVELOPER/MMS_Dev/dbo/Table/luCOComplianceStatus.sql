/****** Object:  Table [dbo].[luCOComplianceStatus]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.luCOComplianceStatus(
	[luCOComplianceStatus_Id] [int] IDENTITY(1,1) NOT NULL,
	[luCOComplianceStatus_Name] [varchar](25) NULL,
PRIMARY KEY CLUSTERED 
(
	[luCOComplianceStatus_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
