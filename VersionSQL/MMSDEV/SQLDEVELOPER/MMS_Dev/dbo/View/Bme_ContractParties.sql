/****** Object:  View [dbo].[Bme_ContractParties]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  M.Asghar(.Net/SQL Consultant)  
-- CREATE date: March 16, 2022 
-- ALTER date: June 10, 2022   
-- Description: 
--              
-- ============================================= 
CREATE VIEW [dbo].[Bme_ContractParties]
AS
SELECT c.MtBilateralContract_ContractId, c.MtBilateralContract_CDPID, c.MtBilateralContract_ContractType, c.MtBilateralContract_Date
, c.BmeStatementData_NtdcDateTime
, c.MtBilateralContract_ContractedQuantity, 
                  c.MtBilateralContract_CapQuantity, c.MtBilateralContract_AncillaryServices, c.MtBilateralContract_Hour, c.MtBilateralContract_Id, c.MtBilateralContract_Percentage, c.SrContractType_Id, 
                  fromParty.PartyRegisteration_Id AS SellerPartyRegisteration_Id, 
				  fromParty.PartyRegisteration_Name AS SellerPartyRegisteration_Name,
				  c.SellerSrCategory_Code AS SellerPartyCategory_Code, 
                  fromParty.PartyType_Code AS SellerPartyType_Code,
				  ToParty.PartyRegisteration_Id AS BuyerPartyRegisteration_Id, ToParty.PartyRegisteration_Name AS BuyerPartyRegisteration_Name, 
                  c.BuyerSrCategory_Code AS BuyerPartyCategory_Code, 
				  ToParty.PartyType_Code AS BuyerPartyType_Code, c.ContractSubType_Id, c.MtSOFileMaster_Id
				  ,cdp.RuCDPDetail_CongestedZoneID,
                  cz.MtCongestedZone_Name
                  ,cdp.RuCDPDetail_TaxZoneID
FROM     dbo.MtBilateralContract AS c 
INNER JOIN
                  dbo.Bme_Parties AS fromParty ON c.MtBilateralContract_SellerMPId = fromParty.PartyRegisteration_Id INNER JOIN
                  dbo.Bme_Parties AS ToParty ON c.MtBilateralContract_BuyerMPId = ToParty.PartyRegisteration_Id

INNER JOIN
 dbo.RuCDPDetail as cdp
  on  cdp.RuCDPDetail_CdpId = c.MtBilateralContract_CDPID
inner join dbo.MtCongestedZone as cz
  on  cdp.RuCDPDetail_CongestedZoneID=cz.MtCongestedZone_Id
WHERE cdp.RuCDPDetail_CongestedZoneID is not null and (c.MtBilateralContract_Deleted = 0) 

EXECUTE sys.sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "c"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 340
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "fromParty"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 268
               Right = 260
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ToParty"
            Begin Extent = 
               Top = 270
               Left = 38
               Bottom = 400
               Right = 260
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1176
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1356
         SortOrder = 1416
         GroupBy = 1350
         Filter = 1356
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'Bme_ContractParties'
EXECUTE sys.sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = N'1', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'Bme_ContractParties'
