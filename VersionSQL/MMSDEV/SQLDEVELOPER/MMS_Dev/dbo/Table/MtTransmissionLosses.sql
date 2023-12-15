/****** Object:  Table [dbo].[MtTransmissionLosses]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtTransmissionLosses(
	[MtTransmissionLosses_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtTranmissionLossesImportInfo_Id] [decimal](18, 0) NULL,
	[MtTransmissionLosses_NtdcDateTime] [datetime] NULL,
	[MtTransmissionLosses_TspName] [varchar](20) NULL,
	[MtTransmissionLosses_importMWh] [decimal](18, 4) NULL,
	[MtTransmissionLosses_exportMWh] [decimal](18, 4) NULL,
	[MtTransmissionLosses_tranmissionLossMWh] [decimal](18, 4) NULL,
	[MtTransmissionLosses_CreatedOn] [datetime] NULL,
	[MtTransmissionLosses_CreatedBy] [decimal](18, 0) NULL,
	[MtTransmissionLosses_ModifiedOn] [datetime] NULL,
	[MtTransmissionLosses_ModifiedBy] [decimal](18, 0) NULL,
	[MtTransmissionLosses_IsDeleted] [bit] NULL,
	[MtTransmissionLosses_ReadingDate] [date] NULL,
	[MtTransmissionLosses_ReadingHour] [int] NULL,
 CONSTRAINT [PK__MtTransLosses__D1E3F8A99941A9FC] PRIMARY KEY CLUSTERED 
(
	[MtTransmissionLosses_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
