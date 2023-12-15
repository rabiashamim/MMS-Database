/****** Object:  Table [dbo].[MtFCCAGeneratorHistory]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtFCCAGeneratorHistory(
	[MtFCCAGeneratorHistory_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtFCCAGenerator_Id] [decimal](18, 0) NULL,
	[MtFCCAMaster_Id] [decimal](18, 0) NOT NULL,
	[MtFCCMaster_Id] [decimal](18, 0) NULL,
	[MtGenerator_Id] [decimal](18, 0) NOT NULL,
	[MtFCCAGenerator_IFC] [decimal](25, 13) NULL,
	[MtFCCAGenerator_KEShare] [decimal](25, 13) NULL,
	[MtFCCAGenerator_WithoutKE] [decimal](25, 13) NULL,
	[MtFCCAGenerator_CreatedBy] [int] NOT NULL,
	[MtFCCAGenerator_CreatedOn] [datetime] NOT NULL,
	[MtFCCAGenerator_ModifiedBy] [int] NULL,
	[MtFCCAGenerator_ModifiedOn] [datetime] NULL,
	[MtFCCAGenerator_IsDeleted] [bit] NOT NULL,
	[MtFCCAGeneratorHistory_CreatedDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[MtFCCAGeneratorHistory_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.MtFCCAGeneratorHistory ADD  DEFAULT ((0)) FOR [MtFCCAGenerator_IsDeleted]
