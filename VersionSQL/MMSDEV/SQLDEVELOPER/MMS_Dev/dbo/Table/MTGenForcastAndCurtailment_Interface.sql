/****** Object:  Table [dbo].[MTGenForcastAndCurtailment_Interface]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MTGenForcastAndCurtailment_Interface(
	[MTGenForcastAndCurtailment_Interface_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MTGenForcastAndCurtailment_Interface_RowNumber] [bigint] NOT NULL,
	[MtSOFileMaster_Id] [decimal](18, 0) NOT NULL,
	[MtGenerator_Id] [nvarchar](max) NULL,
	[MTGenForcastAndCurtailment_Interface_Date] [nvarchar](max) NULL,
	[MTGenForcastAndCurtailment_Interface_Hour] [nvarchar](max) NULL,
	[MTGenForcastAndCurtailment_Interface_Forecast_MW] [nvarchar](max) NULL,
	[MTGenForcastAndCurtailment_Interface_Curtailemnt_MW] [nvarchar](max) NULL,
	[MTGenForcastAndCurtailment_Interface_IsValid] [bit] NULL,
	[MTGenForcastAndCurtailment_Interface_Message] [nvarchar](max) NULL,
	[MTGenForcastAndCurtailment_IsDeleted] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[MTGenForcastAndCurtailment_Interface_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
