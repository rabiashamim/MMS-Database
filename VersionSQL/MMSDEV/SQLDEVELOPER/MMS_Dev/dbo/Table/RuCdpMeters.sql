/****** Object:  Table [dbo].[RuCdpMeters]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.RuCdpMeters(
	[RuCdpMeters_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[RuCdpMeters_MeterId] [decimal](10, 0) NOT NULL,
	[RuCDPDetail_CdpId] [varchar](100) NOT NULL,
	[RuCdpMeters_DeviceName] [varchar](100) NULL,
	[RuCdpMeters_Status] [varchar](100) NULL,
	[RuCdpMeters_MeterNo] [decimal](18, 0) NULL,
	[RuCdpMeters_MeterQualifier] [varchar](200) NULL,
	[RuCdpMeters_MeterModelType] [varchar](200) NULL,
	[RuCdpMeters_Latitude] [varchar](200) NULL,
	[RuCdpMeters_Longitude] [varchar](200) NULL,
	[RuCdpMeters_MeterType] [varchar](50) NULL,
	[RuCdpMeters_EffectiveFrom] [datetime] NULL,
	[RuCdpMeters_EffectiveTo] [datetime] NULL,
	[RuCdpMeters_CreatedDateTime] [datetime] NULL,
	[RuCdpMeters_UpdatedDateTime] [datetime] NULL,
	[RuCdpMeters_CreatedBy] [decimal](18, 0) NULL,
	[RuCdpMeters_CreatedOn] [datetime] NOT NULL,
	[RuCdpMeters_ModifiedBy] [decimal](18, 0) NULL,
	[RuCdpMeters_ModifiedOn] [datetime] NULL,
	[RuCdpMeters_IsDeleted] [datetime] NULL,
 CONSTRAINT [PK__RuCdpMet__0594C43935030F1F] PRIMARY KEY CLUSTERED 
(
	[RuCdpMeters_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
