/****** Object:  Table [dbo].[SrSubContractType]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.SrSubContractType(
	[SrSubContractType] [int] NOT NULL,
	[SrContractType_Id] [int] NULL,
	[SrSubContractType_Name] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[SrSubContractType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.SrSubContractType  WITH CHECK ADD FOREIGN KEY([SrContractType_Id])
REFERENCES [dbo].[SrContractType] ([SrContractType_Id])
