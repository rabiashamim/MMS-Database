/****** Object:  Table [dbo].[MarginalPriceAPI]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MarginalPriceAPI(
	[MarginalPriceAPI_ID] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[Date] [varchar](200) NULL,
	[Hour] [varchar](5) NULL,
	[MARGINAL_PRICE] [varchar](100) NULL,
	[MtSOFileMaster_Id] [decimal](18, 0) NULL,
	[CreatedBy] [varchar](50) NULL,
	[CreatedAt] [datetime] NULL,
	[ModifiedBy] [varchar](50) NULL,
	[ModifiedAt] [datetime] NULL,
	[IsDeleted] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[MarginalPriceAPI_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.MarginalPriceAPI ADD  DEFAULT (getdate()) FOR [CreatedAt]
ALTER TABLE dbo.MarginalPriceAPI ADD  DEFAULT ((0)) FOR [IsDeleted]
ALTER TABLE dbo.MarginalPriceAPI  WITH CHECK ADD  CONSTRAINT [fk_OrderDetails_Orders] FOREIGN KEY([MtSOFileMaster_Id])
REFERENCES [dbo].[MtSOFileMaster] ([MtSOFileMaster_Id])
ALTER TABLE dbo.MarginalPriceAPI CHECK CONSTRAINT [fk_OrderDetails_Orders]
