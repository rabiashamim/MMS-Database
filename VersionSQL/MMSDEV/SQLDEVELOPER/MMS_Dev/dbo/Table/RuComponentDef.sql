/****** Object:  Table [dbo].[RuComponentDef]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[RuComponentDef](
	[RuComponentDef_ID] [decimal](18, 0) NOT NULL,
	[RuComponentDef_StepID] [decimal](18, 0) NULL,
	[RuComponentDef_RegionName] [nvarchar](50) NULL,
	[RuComponentDef_ComponentName] [nvarchar](200) NULL,
	[RuComponentDef_TargetColumnType] [nvarchar](200) NULL,
	[RuComponentDef_DataType] [nvarchar](50) NULL,
	[RuComponentDef_ConversionRequired] [bit] NULL,
	[RuComponentDef_DataUnit] [nvarchar](50) NULL,
	[RuComponentDef_Sequence] [int] NULL,
	[RuComponentDef_SourceTable] [nvarchar](200) NULL,
	[RuComponentDef_SourceColumnName] [nvarchar](200) NULL,
	[RuComponentDef_SourceColumnType] [nvarchar](200) NULL,
	[RuComponentDef_MappedWithColumn] [nchar](10) NULL,
	[RuComponentDef_Formula] [nvarchar](1000) NULL,
	[RuComponentDef_EffectiveDateFrom] [date] NULL,
	[RuComponentDef_EffectiveDateTo] [date] NULL,
	[RuComponentDef_CreatedBy] [decimal](18, 0) NULL,
	[RuComponentDef_CreatedOn] [datetime] NULL,
	[RuComponentDef_ModifiedBy] [decimal](18, 0) NULL,
	[RuComponentDef_ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_Component] PRIMARY KEY CLUSTERED 
(
	[RuComponentDef_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
