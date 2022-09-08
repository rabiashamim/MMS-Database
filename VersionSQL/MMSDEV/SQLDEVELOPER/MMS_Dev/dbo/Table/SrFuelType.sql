/****** Object:  Table [dbo].[SrFuelType]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[SrFuelType](
	[SrFuelType_Code] [varchar](4) NOT NULL,
	[SrFuelType_Name] [varchar](50) NOT NULL,
	[SrTechnologyType_Code] [varchar](4) NULL,
	[SrFuelType_CreatedBy] [decimal](18, 0) NULL,
	[SrFuelType_CreatedOn] [datetime] NULL,
	[SrFuelType_ModifiedBy] [decimal](18, 0) NULL,
	[SrFuelType_ModifiedOn] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[SrFuelType_Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[SrFuelType]  WITH CHECK ADD FOREIGN KEY([SrTechnologyType_Code])
REFERENCES [dbo].[SrTechnologyType] ([SrTechnologyType_Code])
