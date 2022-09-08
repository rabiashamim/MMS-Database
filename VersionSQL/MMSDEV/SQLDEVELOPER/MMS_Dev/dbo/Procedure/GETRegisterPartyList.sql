/****** Object:  Procedure [dbo].[GETRegisterPartyList]    Committed by VersionSQL https://www.versionsql.com ******/

 CREATE PROCEDURE [dbo].[GETRegisterPartyList]    
    
 AS    
 BEGIN    
     
 SELECT     
                          mpr.MtPartyRegisteration_Id    
                          , mpr.MtPartyRegisteration_Name    
                          , srp.SrPartyType_Name    
                          , ls.LuStatus_Name
						  , lss.LuStatus_Name as Approval_Status
        ,ISNULL((Select TOP 1  CONVERT(date,MtRegisterationActivities_CreatedOn) FROM MtRegisterationActivities WHERE MtPartyRegisteration_Id= mpr.MtPartyRegisteration_Id order by 1 desc ),GETUTCDATE()) AS MtRegisterationActivities_CreatedOn    
                          ,SrCategory_Name = STUFF((SELECT ',' + sc.SrCategory_Name FROM  [dbo].[SrCategory] sc    
                           LEFT JOIN [dbo].[MtPartyCategory] mpc1    
                           ON sc.SrCategory_Code=mpc1.SrCategory_Code    and ISNULL( mpc1.isDeleted,0)=0
                           INNER JOIN [dbo].[MtPartyRegisteration] mpr1    
                           ON mpc1.MtPartyRegisteration_Id=mpr1.MtPartyRegisteration_Id    
                           where mpr.MtPartyRegisteration_Id= mpr1.MtPartyRegisteration_Id
							and ISNULL(mpc1.isDeleted,0)=0
						   FOR XML PATH('') ), 1, 1, '')    
    
                         FROM [dbo].[MtPartyRegisteration] mpr    
                   INNER JOIN     
                        [dbo].[SrPartyType] srp    
                         ON     
                        mpr.SrPartyType_Code = srp.SrPartyType_Code
						INNER JOIN 
						LuStatus lss on mpr.LuStatus_Code_Approval=lss.LuStatus_Code
							AND lss.LuStatus_Category = 'PARTYAPPROVAL'
                         INNER JOIN     
                        [dbo].[LuStatus] ls    
                         ON     
                        mpr.LuStatus_Code_Applicant=ls.LuStatus_Code 
				   LEFT JOIN     
                        MtPartyCategory mpc    
                         ON   mpr.MtPartyRegisteration_Id=mpc.MtPartyRegisteration_Id    
						 and isNull(mpc.isDeleted,0)=0
						where isNull(mpr.isDeleted,0)=0
                            
                        --  where ISNULL(mpc.isDeleted,0)=0

                      
                            GROUP BY     
                        mpr.MtPartyRegisteration_Id, mpr.MtPartyRegisteration_Name, srp.SrPartyType_Name, ls.LuStatus_Name, lss.LuStatus_Name    
         order by mpr.MtPartyRegisteration_Id desc  
    
    END
