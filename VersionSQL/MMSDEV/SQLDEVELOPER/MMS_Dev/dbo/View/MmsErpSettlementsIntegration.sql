/****** Object:  View [dbo].[MmsErpSettlementsIntegration]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE VIEW dbo.MmsErpSettlementsIntegration
AS
SELECT MmsErpData_Id AS MMS_INT_ID, MmsErpData_StatementType AS SETT_STATEMENT_TYPE, MmsErpData_Month AS SETTLEMENT_MONTH, MmsErpData_MpId AS MP_ID, MmsErpData_MpType AS MP_TYPE, 
                  MmsErpData_SettlementType AS SETTLEMENT_TYPE, MmsErpData_PssAmount AS PSS_AMOUNT, MmsErpData_FssAmount AS FSS_AMOUNT, MmsErpData_DeltaAmount AS DELTA_AMOUNT, 
                  MmsErpData_TotalPssAmount AS TOTAL_PSS_AMOUNT, MmsErpData_TotalFssAmount AS TOTAL_FSS_AMOUNT, MmsErpData_TotalDeltaAmount AS TOTAL_DELTA_AMOUNT, MmsErpData_TransferedToERP AS TT_ERP, 
                  MmsErpData_ReadFromMms AS RF_MMS, MmsErpData_CreatedOn AS Creatio_Date_Time
FROM     dbo.MmsErpData
WHERE  MmsErpData_TransferedToERP=0 or MmsErpData_ReadFromMms=0

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
         Begin Table = "MmsErpData"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 170
               Right = 365
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'MmsErpSettlementsIntegration'
EXECUTE sys.sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = N'1', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'MmsErpSettlementsIntegration'
