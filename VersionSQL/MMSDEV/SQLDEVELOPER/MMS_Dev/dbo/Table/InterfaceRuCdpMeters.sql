/****** Object:  Table [dbo].[InterfaceRuCdpMeters]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[InterfaceRuCdpMeters](
	[InterfaceRuCdpMeters_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[InterfaceRuCdpMeters_MeterId] [decimal](18, 0) NOT NULL,
	[InterfaceRuCDPDetail_CdpId] [varchar](100) NOT NULL,
	[InterfaceRuCdpMeters_DeviceName] [varchar](100) NULL,
	[InterfaceRuCdpMeters_Status] [varchar](10) NULL,
	[InterfaceRuCdpMeters_MeterNo] [decimal](18, 0) NULL,
	[InterfaceRuCdpMeters_MeterQualifier] [varchar](200) NULL,
	[InterfaceRuCdpMeters_MeterModelType] [varchar](200) NULL,
	[InterfaceRuCdpMeters_Latitude] [varchar](200) NULL,
	[InterfaceRuCdpMeters_Longitude] [varchar](200) NULL,
	[InterfaceRuCdpMeters_MeterType] [varchar](50) NULL,
	[InterfaceRuCdpMeters_EffectiveFrom] [datetime] NULL,
	[InterfaceRuCdpMeters_EffectiveTo] [datetime] NULL,
	[InterfaceRuCdpMeters_CreatedDateTime] [datetime] NULL,
	[InterfaceRuCdpMeters_UpdatedDateTime] [datetime] NULL,
	[InterfaceRuCdpMeters_CreatedOn] [datetime] NOT NULL,
	[InterfaceRuCdpMeters_ModifiedOn] [datetime] NULL,
	[InterfaceRuCdpMeters_IsDeleted] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[InterfaceRuCdpMeters_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
