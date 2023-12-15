/****** Object:  Table [dbo].[MtBVMDataHeader]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtBVMDataHeader(
	[MtBVMDataHeader_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtBVMDataHeader_Month] [decimal](18, 0) NOT NULL,
	[MtBVMDataHeader_Year] [decimal](18, 0) NOT NULL,
	[MtBVMDataHeader_TotalCDPs] [decimal](18, 0) NULL,
	[MtBVMDataHeader_TotalActiveCDPs] [decimal](18, 0) NULL,
	[MtBVMDataHeader_ConnectedCDPs] [decimal](18, 0) NULL,
	[MtBVMDataHeader_BVMRecords] [decimal](18, 0) NULL,
	[MtBVMDataHeader_LastUpdatedOn] [datetime] NULL,
	[MtBVMDataHeader_TotalRecords] [decimal](18, 0) NULL,
	[MtBVMDataHeader_DataStatus] [decimal](18, 4) NULL,
	[MtBVMDataHeader_CreatedOn] [datetime] NOT NULL,
	[MtBVMDataHeader_CreatedBy] [int] NOT NULL,
	[MtBVMDataHeader_UpdatedOn] [datetime] NULL,
	[MtBVMDataHeader_UpdatedBy] [int] NULL,
	[MtBVMDataHeader_IsDeleted] [bit] NULL,
	[MtBVMDataHeader_MonthName] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[MtBVMDataHeader_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.MtBVMDataHeader ADD  DEFAULT ((0)) FOR [MtBVMDataHeader_IsDeleted]
