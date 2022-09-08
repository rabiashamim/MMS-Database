/****** Object:  Table [dbo].[MtMarginalPrice]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[MtMarginalPrice](
	[MtMarginalPrice_Id] [decimal](18, 0) NOT NULL,
	[MtSOFileMaster_Id] [decimal](18, 0) NOT NULL,
	[MtMarginalPrice_Date] [date] NOT NULL,
	[MtMarginalPrice_Hour] [varchar](5) NOT NULL,
	[MtMarginalPrice_Price] [decimal](20, 4) NOT NULL,
	[MtMarginalPrice_CreatedBy] [int] NOT NULL,
	[MtMarginalPrice_CreatedOn] [datetime] NOT NULL,
	[MtMarginalPrice_ModifiedBy] [int] NULL,
	[MtMarginalPrice_ModifiedOn] [datetime] NULL,
	[MtMarginalPrice_IsDeleted] [bit] NULL,
	[BmeStatementData_NtdcDateTime] [datetime] NULL,
 CONSTRAINT [PK__MtMargin__6C6B11EDF0F04B98] PRIMARY KEY CLUSTERED 
(
	[MtMarginalPrice_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [dbo].[MtMarginalPrice]  WITH CHECK ADD  CONSTRAINT [FK__MtMargina__MtSOF__793DFFAF] FOREIGN KEY([MtSOFileMaster_Id])
REFERENCES [dbo].[MtSOFileMaster] ([MtSOFileMaster_Id])
ALTER TABLE [dbo].[MtMarginalPrice] CHECK CONSTRAINT [FK__MtMargina__MtSOF__793DFFAF]
