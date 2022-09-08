/****** Object:  View [dbo].[Bme_CdpOwnerParties]    Committed by VersionSQL https://www.versionsql.com ******/

-- =============================================  
-- Author:  M.Asghar(.Net/SQL Consultant)  
-- CREATE date: March 16, 2022 
-- ALTER date: June 10, 2022   
-- Description: 
--              
-- ============================================= 
/* select * from [dbo].[Bme_CdpOwnerParties]*/
CREATE VIEW [dbo].[Bme_CdpOwnerParties]
AS
SELECT DISTINCT cdp.RuCDPDetail_Id, cdp.RuCDPDetail_CdpId,cdp.RuCDPDetail_CongestedZoneID,cdp.MtCongestedZone_Name,
cdp.RuCDPDetail_TaxZoneID, P.MtPartyRegisteration_Id AS OwnerPartyRegisteration_Id,
 P.MtPartyRegisteration_Name AS OwnerPartyRegisteration_Name, P.SrPartyType_Code AS OwnerPartyType_Code,
						PC.SrCategory_Code as OwnerPartyCategory_Code,
						cdp.FromPartyRegisteration_Id, 
                        cdp.FromPartyRegisteration_Name,
                         cdp.FromPartyType_Code, 
                  cdp.FromPartyCategory_Code,
                   cdp.ToPartyRegisteration_Id, 
                   cdp.ToPartyRegisteration_Name,
                    cdp.ToPartyType_Code, 
                    cdp.ToPartyCategory_Code,
                    
                     cdp.IsARE
                     ,cdp.IsThermal
                     ,cdp.IsLegacy
                     ,cdp.RuCDPDetail_IsEnergyImported
                        ,ISNULL(P.MtPartyRegisteration_IsPowerPool,0) AS IsPowerPool
                        ,CDP.RuCDPDetail_EffectiveFrom as EffectiveFrom,
                        CDP.RuCDPDetail_EffectiveTo as EffectiveTo
FROM     dbo.MtPartyRegisteration AS P INNER JOIN                  
                  dbo.MtPartyCategory AS PC ON PC.MtPartyRegisteration_Id = P.MtPartyRegisteration_Id INNER JOIN
                  dbo.MtConnectedMeter AS MC ON MC.MtPartyCategory_Id = PC.MtPartyCategory_Id INNER JOIN
                  dbo.Bme_CdpParties AS cdp ON MC.MtCDPDetail_Id = cdp.RuCDPDetail_Id
                  where p.isDeleted=0 and PC.isDeleted=0 AND MC.MtConnectedMeter_isDeleted=0
				  and p.LuStatus_Code_Applicant='AACT' and P.SrPartyType_Code='MP'

UNION
SELECT 	
        CDP.RuCDPDetail_Id
        ,CDP.[RuCDPDetail_CdpId]  
	    ,CDP.RuCDPDetail_CongestedZoneID
       ,CDP.MtCongestedZone_Name
       ,cdp.RuCDPDetail_TaxZoneID
	   ,CDP.FromPartyRegisteration_Id as OwnerPartyRegisteration_Id
       ,cdp.FromPartyRegisteration_Name as OwnerPartyRegisteration_Name	 
       ,cdp.FromPartyType_Code as OwnerPartyType_Code
       ,cdp.FromPartyCategory_Code as OwnerPartyCategory_Code
	   
       ,cdp.FromPartyRegisteration_Id
      ,cdp.FromPartyRegisteration_Name	 
      ,cdp.FromPartyType_Code
      ,cdp.FromPartyCategory_Code	  
      ,cdp.ToPartyRegisteration_Id
      ,cdp.ToPartyRegisteration_Name	 
       ,cdp.ToPartyType_Code
      ,cdp.ToPartyCategory_Code
	  
	   ,CDP.IsARE
	   ,CDP.IsThermal
       ,CDP.IsLegacy
	   ,CDP.RuCDPDetail_IsEnergyImported
	   ,cdp.FromPartyIsPowerPool as IsPowerPool    
       ,CDP.RuCDPDetail_EffectiveFrom as EffectiveFrom,
       CDP.RuCDPDetail_EffectiveTo as EffectiveTo   
      FROM 
   	  Bme_CdpParties as cdp   
      WHERE  cdp.FromPartyType_Code='MP'       
       UNION       
SELECT 	
       CDP.RuCDPDetail_Id
        ,CDP.[RuCDPDetail_CdpId]  
	    ,CDP.RuCDPDetail_CongestedZoneID
       ,CDP.MtCongestedZone_Name
       ,cdp.RuCDPDetail_TaxZoneID
	   ,CDP.ToPartyRegisteration_Id as OwnerPartyRegisteration_Id
       ,cdp.ToPartyRegisteration_Name as OwnerPartyRegisteration_Name	 
       ,cdp.ToPartyType_Code as OwnerPartyType_Code
       ,cdp.ToPartyCategory_Code as OwnerPartyCategory_Code
	   

      ,cdp.FromPartyRegisteration_Id
      ,cdp.FromPartyRegisteration_Name	 
      ,cdp.FromPartyType_Code
      ,cdp.FromPartyCategory_Code
	  
      ,cdp.ToPartyRegisteration_Id
      ,cdp.ToPartyRegisteration_Name	 
       ,cdp.ToPartyType_Code
      ,cdp.ToPartyCategory_Code
	  
	   ,CDP.IsARE
	   ,CDP.IsThermal
       ,CDP.IsLegacy
	   ,CDP.RuCDPDetail_IsEnergyImported
	   ,cdp.ToPartyIsPowerPool as IsPowerPool    
       ,CDP.RuCDPDetail_EffectiveFrom as EffectiveFrom,
       CDP.RuCDPDetail_EffectiveTo as EffectiveTo   
      FROM 
   	  Bme_CdpParties as cdp   
      WHERE  cdp.ToPartyType_Code='MP';                        

EXECUTE sys.sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[26] 4[35] 2[20] 3) )"
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
         Top = -120
         Left = 0
      End
      Begin Tables = 
         Begin Table = "P"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 170
               Right = 369
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PC"
            Begin Extent = 
               Top = 175
               Left = 48
               Bottom = 338
               Right = 369
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "MC"
            Begin Extent = 
               Top = 343
               Left = 48
               Bottom = 506
               Right = 386
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cdp"
            Begin Extent = 
               Top = 511
               Left = 48
               Bottom = 674
               Right = 351
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
         Table = 6468
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'Bme_CdpOwnerParties'
EXECUTE sys.sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = N'1', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'Bme_CdpOwnerParties'
