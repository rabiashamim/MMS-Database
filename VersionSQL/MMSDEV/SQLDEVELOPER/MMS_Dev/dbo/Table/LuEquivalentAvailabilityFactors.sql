/****** Object:  Table [dbo].[LuEquivalentAvailabilityFactors]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.LuEquivalentAvailabilityFactors(
	[LuEquivalentAvailabilityFactorsId] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[SrFuelType_Code] [varchar](4) NULL,
	[LuEquivalentAvailabilityFactors_EffectiveFrom] [date] NULL,
	[LuEquivalentAvailabilityFactors_EffectiveTo] [date] NULL,
	[LuEquivalentAvailabilityFactors_Value] [decimal](18, 5) NOT NULL,
	[ LuEquivalentAvailabilityFactors_CreatedBy] [int] NOT NULL,
	[ LuEquivalentAvailabilityFactors_CreatedOn] [date] NOT NULL,
	[ LuEquivalentAvailabilityFactors_ModifiedBy] [int] NULL,
	[ LuEquivalentAvailabilityFactors_ModifiedOn] [date] NULL,
	[ LuEquivalentAvailabilityFactors_IsDeleted] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[LuEquivalentAvailabilityFactorsId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.LuEquivalentAvailabilityFactors ADD  DEFAULT ((0)) FOR [ LuEquivalentAvailabilityFactors_IsDeleted]
ALTER TABLE dbo.LuEquivalentAvailabilityFactors  WITH CHECK ADD FOREIGN KEY([SrFuelType_Code])
REFERENCES [dbo].[SrFuelType] ([SrFuelType_Code])
