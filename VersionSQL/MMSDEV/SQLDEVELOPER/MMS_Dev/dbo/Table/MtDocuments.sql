/****** Object:  Table [dbo].[MtDocuments]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtDocuments(
	[MtDocuments_ID] [int] NOT NULL,
	[RuDocument_ID] [int] NULL,
	[MtPartyCategory_Id] [int] NULL,
	[MtDocuments_FlieName] [varchar](100) NULL,
	[MtDocuments_Description] [varchar](max) NULL,
	[MtDocuments_Size] [int] NULL,
	[MtDocuments_Path] [varchar](max) NULL,
	[MtDocuments_CreatedBy] [int] NULL,
	[MtDocuments_CreatedOn] [datetime] NULL,
	[MtDocuments_ModifiedBy] [int] NULL,
	[MtDocuments_ModiifiedOn] [datetime] NULL,
	[MtDocuments_FileTitle] [varchar](max) NULL,
	[MtRegisterationActivity_Id] [decimal](18, 0) NULL,
	[MtDocuments_isDeleted] [bit] NULL,
	[MtContractRegistration_Id] [decimal](18, 0) NULL,
PRIMARY KEY CLUSTERED 
(
	[MtDocuments_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE dbo.MtDocuments ADD  DEFAULT ((0)) FOR [MtDocuments_isDeleted]
