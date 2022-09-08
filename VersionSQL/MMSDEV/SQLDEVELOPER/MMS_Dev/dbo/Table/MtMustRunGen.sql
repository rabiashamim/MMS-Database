/****** Object:  Table [dbo].[MtMustRunGen]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MtMustRunGen](
	[MtMustRunGen_Id] [decimal](18, 0) NOT NULL,
	[MtSOFileMaster_Id] [decimal](18, 0) NOT NULL,
	[MtGenerationUnit_Id] [int] NULL,
	[MtMustRunGen_Date] [date] NOT NULL,
	[MtMustRunGen_Hour] [varchar](5) NOT NULL,
	[MtMustRunGen_EnergyProduced] [decimal](20, 4) NULL,
	[MtMustRunGen_VariableCost] [decimal](20, 4) NULL,
	[MtMustRunGen_CreatedBy] [int] NOT NULL,
	[MtMustRunGen_CreatedOn] [datetime] NOT NULL,
	[MtMustRunGen_ModifiedBy] [int] NULL,
	[MtMustRunGen_ModifiedOn] [datetime] NULL,
	[MtMustRunGen_IsDeleted] [bit] NULL,
 CONSTRAINT [PK__MtMustRu__B8DF8238E0473741] PRIMARY KEY CLUSTERED 
(
	[MtMustRunGen_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[MtMustRunGen]  WITH CHECK ADD  CONSTRAINT [FK__MtMustRun__MtSOF__7A3223E8] FOREIGN KEY([MtSOFileMaster_Id])
REFERENCES [dbo].[MtSOFileMaster] ([MtSOFileMaster_Id])
ALTER TABLE [dbo].[MtMustRunGen] CHECK CONSTRAINT [FK__MtMustRun__MtSOF__7A3223E8]
