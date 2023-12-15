/****** Object:  Table [dbo].[MyTask]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.MyTask(
	[task_id] [int] IDENTITY(0,1) NOT NULL,
	[name] [varchar](90) NULL,
	[description] [varchar](90) NULL,
	[due_date] [date] NULL,
	[status] [varchar](50) NULL,
	[CreatedBy] [varchar](60) NULL,
	[CreatedAt] [datetime] NULL,
	[ModifiedBy] [varchar](60) NULL,
	[ModifiedAt] [datetime] NULL,
	[IsDeleted] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[task_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.MyTask ADD  DEFAULT (getdate()) FOR [CreatedAt]
ALTER TABLE dbo.MyTask ADD  DEFAULT ((0)) FOR [IsDeleted]
