/****** Object:  Table [dbo].[InterfaceMtTransmissionLosses]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.InterfaceMtTransmissionLosses(
	[InterfaceMtTransmissionLosses_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[InterfaceMtTransmissionLosses_NtdcDateTime] [datetime] NULL,
	[InterfaceMtTransmissionLosses_TspName] [varchar](20) NULL,
	[InterfaceMtTransmissionLosses_importMWh] [decimal](18, 4) NULL,
	[InterfaceMtTransmissionLosses_exportMWh] [decimal](18, 4) NULL,
	[InterfaceMtTransmissionLosses_tranmissionLossMWh] [decimal](18, 4) NULL,
	[InterfaceMtTransmissionLosses_CreatedOn] [datetime] NULL,
	[InterfaceMtTransmissionLosses_ModifiedOn] [datetime] NULL,
	[InterfaceMtTransmissionLosses_IsDeleted] [bit] NULL,
 CONSTRAINT [PK__Interfac__787878] PRIMARY KEY CLUSTERED 
(
	[InterfaceMtTransmissionLosses_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
