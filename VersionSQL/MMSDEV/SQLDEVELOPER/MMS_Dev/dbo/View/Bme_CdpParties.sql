/****** Object:  View [dbo].[Bme_CdpParties]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  M.Asghar(.Net/SQL Consultant)  
-- CREATE date: March 16, 2022 
-- ALTER date: June 10, 2022   
-- Description: 
--              
-- ============================================= 

CREATE VIEW [dbo].[Bme_CdpParties]
AS
SELECT cdp.RuCDPDetail_Id, cdp.RuCDPDetail_CdpId, cdp.RuCDPDetail_LineVoltage, fromParty.PartyRegisteration_Id AS FromPartyRegisteration_Id, 
                  fromParty.PartyRegisteration_Name AS FromPartyRegisteration_Name,fromParty.MPId as FromPartyMPId,fromParty.IsPowerPool as FromPartyIsPowerPool,
				  cdp.RuCDPDetail_FromCustomerCategory AS FromPartyCategory_Code,
				  fromParty.PartyType_Code AS FromPartyType_Code,
				  ToParty.PartyRegisteration_Id AS ToPartyRegisteration_Id, 
                  ToParty.PartyRegisteration_Name AS ToPartyRegisteration_Name, 
				  cdp.RuCDPDetail_ToCustomerCategory AS ToPartyCategory_Code, 
				  ToParty.PartyType_Code AS ToPartyType_Code, ToParty.MPId as ToPartyMPId,toParty.IsPowerPool as ToPartyIsPowerPool
                  ,case when fromParty.IsPowerPool=1 or toParty.IsPowerPool=1 then 1 else 0 END as IsLegacy,
				  cdp.RuCDPDetail_IsEnergyImported,
				  cdp.RuCDPDetail_TaxZoneID
				 ,cdp.RuCDPDetail_CongestedZoneID
                 ,cz.MtCongestedZone_Name,
                ISNULL
                     ((SELECT TOP (1) 1 AS Expr1
                        FROM      dbo.Bme_GuParties as BGU
                        WHERE   (BGU.MtGenerationUnit_Id in(select MtConnectedMeter_UnitId from MtConnectedMeter where  MtCDPDetail_Id=cdp.RuCDPDetail_Id)) AND (BGU.SrTechnologyType_Code IN ('ARE', 'HYD'))), 0) AS IsARE, ISNULL
                      ((SELECT TOP (1) 1 AS Expr1
                        FROM      dbo.Bme_GuParties AS BGU
                        WHERE   (BGU.MtGenerationUnit_Id in(select MtConnectedMeter_UnitId from MtConnectedMeter where  MtCDPDetail_Id=cdp.RuCDPDetail_Id)) AND (BGU.SrTechnologyType_Code = 'THR')), 0) AS IsThermal,
                        CDP.RuCDPDetail_EffectiveFrom,CDP.RuCDPDetail_EffectiveTo
FROM     dbo.RuCDPDetail cdp INNER JOIN
                  dbo.Bme_Parties AS fromParty ON cdp.RuCDPDetail_ConnectedFromID = fromParty.PartyRegisteration_Id INNER JOIN
                  dbo.Bme_Parties AS ToParty ON cdp.RuCDPDetail_ConnectedToID = ToParty.PartyRegisteration_Id
                    inner join dbo.MtCongestedZone as cz
  on  cdp.RuCDPDetail_CongestedZoneID=cz.MtCongestedZone_Id
                  where cdp.RuCDPDetail_CongestedZoneID is not null                  

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
         Begin Table = "RuCDPDetail"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 170
               Right = 357
            End
            DisplayFlags = 280
            TopColumn = 18
         End
         Begin Table = "fromParty"
            Begin Extent = 
               Top = 175
               Left = 48
               Bottom = 316
               Right = 328
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ToParty"
            Begin Extent = 
               Top = 322
               Left = 48
               Bottom = 463
               Right = 328
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
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'Bme_CdpParties'
EXECUTE sys.sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = N'1', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'Bme_CdpParties'
