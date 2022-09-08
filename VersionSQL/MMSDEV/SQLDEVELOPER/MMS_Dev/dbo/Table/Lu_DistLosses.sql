/****** Object:  Table [dbo].[Lu_DistLosses]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Lu_DistLosses](
	[Lu_DistLosses_Id] [decimal](18, 0) NOT NULL,
	[Lu_DistLosses_MP_Id] [decimal](18, 0) NULL,
	[Lu_DistLosses_MP_Name] [nvarchar](50) NULL,
	[Lu_DistLosses_LineVoltage] [int] NULL,
	[Lu_DistLosses_Factor] [decimal](18, 2) NULL,
	[Lu_DistLosses_EffectiveFrom] [date] NULL,
	[Lu_DistLosses_EffectiveTo] [date] NULL,
	[MtPartyRegisteration_Id] [decimal](18, 0) NULL,
	[Lu_DistLosses_CreatedDate] [datetime] NULL,
	[Lu_DistLosses_UpdatedDate] [datetime] NULL,
 CONSTRAINT [PK_Lu_DistLosses] PRIMARY KEY CLUSTERED 
(
	[Lu_DistLosses_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
