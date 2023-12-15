/****** Object:  Table [dbo].[BMCAllocationFactors]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE TABLE dbo.BMCAllocationFactors(
	[BMCAllocationFactors_Id] [decimal](18, 0) IDENTITY(1,1) NOT NULL,
	[BMCAllocationFactors_AllocationFactor] [decimal](18, 2) NULL,
	[MtPartyRegisteration_Id] [decimal](18, 0) NULL,
	[MtStatementProcess_ID] [decimal](18, 0) NULL,
 CONSTRAINT [PK_BMCAllocationFactors] PRIMARY KEY CLUSTERED 
(
	[BMCAllocationFactors_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE dbo.BMCAllocationFactors  WITH CHECK ADD FOREIGN KEY([MtPartyRegisteration_Id])
REFERENCES [dbo].[MtPartyRegisteration] ([MtPartyRegisteration_Id])
ALTER TABLE dbo.BMCAllocationFactors  WITH CHECK ADD FOREIGN KEY([MtStatementProcess_ID])
REFERENCES [dbo].[MtStatementProcess] ([MtStatementProcess_ID])
