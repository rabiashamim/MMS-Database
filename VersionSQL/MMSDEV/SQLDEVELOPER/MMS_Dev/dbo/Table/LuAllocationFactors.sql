/****** Object:  Table [dbo].[LuAllocationFactors]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[LuAllocationFactors](
	[LuAllocationFactors_Id] [int] NOT NULL,
	[MtPartyRegisteration_Id] [decimal](18, 0) NULL,
	[LuAllocationFactors_Factor] [decimal](18, 2) NULL,
	[LuAllocationFactors_StaticCapValue] [decimal](18, 4) NULL,
	[LuAllocationFactors_Entity] [nvarchar](40) NULL,
	[LuAllocationFactors_EffectiveFrom] [datetime] NULL,
	[LuAllocationFactors_EffectiveTo] [datetime] NULL,
	[LuAllocationFactors_CreatedDate] [datetime] NULL,
	[LuAllocationFactors_UpdatedDate] [datetime] NULL,
	[LuAllocationFactors_CreatedBy] [decimal](18, 0) NULL,
	[LuallocationFactors_ModifiedBy] [decimal](18, 0) NULL,
PRIMARY KEY CLUSTERED 
(
	[LuAllocationFactors_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
