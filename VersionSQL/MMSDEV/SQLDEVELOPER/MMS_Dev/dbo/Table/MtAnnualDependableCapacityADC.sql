/****** Object:  Table [dbo].[MtAnnualDependableCapacityADC]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtAnnualDependableCapacityADC(
	[MtAnnualDependableCapacityADC_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtGenerator_Id] [decimal](18, 0) NOT NULL,
	[MtAnnualDependableCapacityADC_Date] [date] NOT NULL,
	[MtAnnualDependableCapacityADC_Value] [decimal](38, 13) NOT NULL,
	[MtAnnualDependableCapacityADC_CreatedBy] [decimal](18, 0) NOT NULL,
	[MtAnnualDependableCapacityADC_CreatedOn] [datetime] NOT NULL,
	[MtAnnualDependableCapacityADC_ModifiedBy] [decimal](18, 0) NULL,
	[MtAnnualDependableCapacityADC_ModifiedOn] [datetime] NULL,
	[MtAnnualDependableCapacityADC_IsDeleted] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[MtAnnualDependableCapacityADC_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.MtAnnualDependableCapacityADC ADD  DEFAULT ((0)) FOR [MtAnnualDependableCapacityADC_IsDeleted]
ALTER TABLE dbo.MtAnnualDependableCapacityADC  WITH CHECK ADD FOREIGN KEY([MtGenerator_Id])
REFERENCES [dbo].[MtGenerator] ([MtGenerator_Id])
