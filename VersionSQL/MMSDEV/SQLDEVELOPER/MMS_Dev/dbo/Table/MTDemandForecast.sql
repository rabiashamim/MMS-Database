/****** Object:  Table [dbo].[MTDemandForecast]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MTDemandForecast(
	[MTDemandForecast_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MTDemandForecast_RowNumber] [bigint] NOT NULL,
	[MtSOFileMaster_Id] [decimal](18, 0) NOT NULL,
	[MtParty_Id] [decimal](18, 0) NOT NULL,
	[MTDemandForecast_Year] [varchar](15) NOT NULL,
	[MTDemandForecast_Max_Demand_during_Peakhours_MW] [decimal](25, 13) NULL,
	[MTDemandForecast_CreatedBy] [int] NOT NULL,
	[MTDemandForecast_CreatedOn] [datetime] NOT NULL,
	[MTDemandForecast_ModifiedBy] [int] NULL,
	[MTDemandForecast_ModifiedOn] [datetime] NULL,
	[MTDemandForecast_IsDeleted] [bit] NULL,
	[MTDemandForecast_CapacityObligation] [decimal](25, 13) NULL,
PRIMARY KEY CLUSTERED 
(
	[MTDemandForecast_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.MTDemandForecast  WITH CHECK ADD FOREIGN KEY([MtParty_Id])
REFERENCES [dbo].[MtPartyRegisteration] ([MtPartyRegisteration_Id])
ALTER TABLE dbo.MTDemandForecast  WITH CHECK ADD FOREIGN KEY([MtSOFileMaster_Id])
REFERENCES [dbo].[MtSOFileMaster] ([MtSOFileMaster_Id])
