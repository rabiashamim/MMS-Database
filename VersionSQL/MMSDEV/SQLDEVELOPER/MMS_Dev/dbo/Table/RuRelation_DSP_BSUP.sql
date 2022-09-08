/****** Object:  Table [dbo].[RuRelation_DSP_BSUP]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[RuRelation_DSP_BSUP](
	[RuRelation_DSP_BSUP_Id] [int] IDENTITY(1,1) NOT NULL,
	[RuRelation_DSP_BSUP_SPName] [varchar](100) NULL,
	[RuRelation_DSP_BSUP_DSP_Id] [decimal](18, 0) NULL,
	[RuRelation_DSP_BSUP_BSUP_Id] [decimal](18, 0) NULL,
PRIMARY KEY CLUSTERED 
(
	[RuRelation_DSP_BSUP_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
