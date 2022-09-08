/****** Object:  Table [dbo].[MtGenerator]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MtGenerator](
	[MtGenerator_Id] [decimal](18, 0) NOT NULL,
	[MtPartyCategory_Id] [decimal](18, 0) NOT NULL,
	[MtGenerator_MeterGeneratorId] [varchar](6) NULL,
	[MtGenerator_Code] [varchar](10) NULL,
	[MtGenerator_Name] [varchar](100) NULL,
	[MtGenerator_NetworkConnectionType] [varchar](30) NULL,
	[MtGenerator_IsDisabled] [bit] NULL,
	[MtGenerator_EffectiveFrom] [datetime] NULL,
	[MtGenerator_EffectiveTo] [datetime] NULL,
	[MtGenerator_CreatedBy] [decimal](18, 0) NOT NULL,
	[MtGenerator_CreatedOn] [datetime] NOT NULL,
	[MtGenerator_ModifiedBy] [decimal](18, 0) NULL,
	[MtGenerator_ModifiedOn] [datetime] NULL,
	[MtGenerator_IsDeleted] [bit] NULL,
	[MtGenerator_Location] [varchar](max) NULL,
	[isDeleted] [bit] NOT NULL,
	[MtGenerator_TotalInstalledCapacity_bk] [int] NULL,
	[MtGenerator_TotalInstalledCapacity] [decimal](18, 4) NULL,
PRIMARY KEY CLUSTERED 
(
	[MtGenerator_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE [dbo].[MtGenerator] ADD  DEFAULT ((0)) FOR [isDeleted]
ALTER TABLE [dbo].[MtGenerator]  WITH CHECK ADD FOREIGN KEY([MtPartyCategory_Id])
REFERENCES [dbo].[MtPartyCategory] ([MtPartyCategory_Id])
