/****** Object:  Table [dbo].[MTGenForcastAndCurtailment]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MTGenForcastAndCurtailment(
	[MTGenForcastAndCurtailment_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MTGenForcastAndCurtailment_RowNumber] [bigint] NOT NULL,
	[MtSOFileMaster_Id] [decimal](18, 0) NOT NULL,
	[MtGenerator_Id] [decimal](18, 0) NOT NULL,
	[MTGenForcastAndCurtailment_Date] [date] NOT NULL,
	[MTGenForcastAndCurtailment_Hour] [int] NOT NULL,
	[MTGenForcastAndCurtailment_Forecast_MW] [decimal](25, 13) NULL,
	[MTGenForcastAndCurtailment_Curtailemnt_MW] [decimal](25, 13) NULL,
	[MTGenForcastAndCurtailment_CreatedBy] [int] NOT NULL,
	[MTGenForcastAndCurtailment_CreatedOn] [datetime] NOT NULL,
	[MTGenForcastAndCurtailment_ModifiedBy] [int] NULL,
	[MTGenForcastAndCurtailment_ModifiedOn] [datetime] NULL,
	[MTGenForcastAndCurtailment_IsDeleted] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[MTGenForcastAndCurtailment_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.MTGenForcastAndCurtailment  WITH CHECK ADD FOREIGN KEY([MtGenerator_Id])
REFERENCES [dbo].[MtGenerator] ([MtGenerator_Id])
ALTER TABLE dbo.MTGenForcastAndCurtailment  WITH CHECK ADD FOREIGN KEY([MtSOFileMaster_Id])
REFERENCES [dbo].[MtSOFileMaster] ([MtSOFileMaster_Id])
