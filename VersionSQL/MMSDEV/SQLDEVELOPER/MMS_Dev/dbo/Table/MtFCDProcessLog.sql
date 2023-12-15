/****** Object:  Table [dbo].[MtFCDProcessLog]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MtFCDProcessLog(
	[MtFCDProcessLog_ID] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[MtFCDMaster_Id] [decimal](18, 0) NULL,
	[MtFCDProcessLog_Message] [nvarchar](max) NULL,
	[MtFCDProcessLog_CreatedBy] [int] NULL,
	[MtFCDProcessLog_CreatedOn] [datetime] NULL,
	[MtFCDProcessLog_ModifiedBy] [int] NULL,
	[MtFCDProcessLog__ModifiedOn] [datetime] NULL,
	[MtFCDProcessLog_ErrorLevel] [varchar](max) NULL,
	[SrFCDProcessDef_Id] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[MtFCDProcessLog_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

ALTER TABLE dbo.MtFCDProcessLog  WITH CHECK ADD FOREIGN KEY([SrFCDProcessDef_Id])
REFERENCES [dbo].[SrFCDProcessDef] ([SrFCDProcessDef_Id])
