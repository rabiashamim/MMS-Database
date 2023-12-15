/****** Object:  Table [dbo].[PeriodType]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.PeriodType(
	[PeriodTypeID] [int] NOT NULL,
	[PeriodTypeName] [varchar](100) NULL,
 CONSTRAINT [PK_PeriodType] PRIMARY KEY CLUSTERED 
(
	[PeriodTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
