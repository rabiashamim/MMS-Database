/****** Object:  Table [dbo].[MtGenerationUnitlogs]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MtGenerationUnitlogs](
	[MtGenerationUnitlogs_Id] [decimal](18, 0) NOT NULL,
	[MtGenerationUnit_Id] [decimal](18, 0) NOT NULL,
	[MtGenerator_Id] [decimal](18, 0) NOT NULL,
	[SrTechnologyType_Code] [varchar](4) NULL,
	[SrFuelType_Code] [varchar](4) NULL,
	[MtGenerationUnit_UnitNumber] [varchar](10) NULL,
	[MtGenerationUnit_InstalledCapacity_KW] [int] NULL,
	[MtGenerationUnit_location] [varchar](50) NULL,
	[MtGenerationUnit_IsDisabled] [bit] NULL,
	[MtGenerationUnit_EffectiveFrom] [datetime] NULL,
	[MtGenerationUnit_EffectiveTo] [datetime] NULL,
	[MtGenerationUnit_CreatedBy] [decimal](18, 0) NOT NULL,
	[MtGenerationUnit_CreatedOn] [datetime] NOT NULL,
	[MtGenerationUnit_ModifiedBy] [decimal](18, 0) NULL,
	[MtGenerationUnit_ModifiedOn] [datetime] NULL,
	[MtGenerationUnit_IsDeleted] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[MtGenerationUnitlogs_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[MtGenerationUnitlogs]  WITH CHECK ADD FOREIGN KEY([MtGenerationUnit_Id])
REFERENCES [dbo].[MtGenerationUnit] ([MtGenerationUnit_Id])
