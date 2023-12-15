/****** Object:  Table [dbo].[SrFCDProcessDef]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.SrFCDProcessDef(
	[SrFCDProcessDef_Id] [int] IDENTITY(1,1) NOT NULL,
	[SrFCDProcessDef_Name] [varchar](50) NOT NULL,
	[SrFCDProcessDef_CreatedBy] [int] NOT NULL,
	[SrFCDProcessDef_CreatedOn] [datetime] NOT NULL,
	[SrFCDProcessDef_ModifiedBy] [int] NULL,
	[SrFCDProcessDef_ModifiedOn] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[SrFCDProcessDef_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
