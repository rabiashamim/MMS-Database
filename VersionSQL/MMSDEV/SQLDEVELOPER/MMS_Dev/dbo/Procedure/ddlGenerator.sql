/****** Object:  Procedure [dbo].[ddlGenerator]    Committed by VersionSQL https://www.versionsql.com ******/

-- ddlGenerator 76    
CREATE PROCEDURE [dbo].[ddlGenerator]    
@pPartyCategoryId INT = null 

AS    
BEGIN    

   
 --select     
 --  mgu.MtGenerationUnit_Id  as Id    
 -- ,mgu.MtGenerationUnit_UnitName as GeneratorName    
 --from     
 -- [dbo].[MtGenerator]  G  
 -- JOIN MtGenerationUnit mgu ON mgu.MtGenerator_Id = G.MtGenerator_Id
 --  Where     
 -- G.MtPartyCategory_Id= @pPartyCategoryId    
 -- AND ISNULL(G.IsDeleted,0)=0  
 -- AND ISNULL(mgu.IsDeleted,0)=0  


 Declare @vCategoryCode    as varchar(4)=null;

 select @vCategoryCode=SrCategory_Code from MtPartyCategory where MtPartyCategory_Id=@pPartyCategoryId

 IF @vCategoryCode='BPC' or  @vCategoryCode='EBPC' 
				select     
				G.MtGenerator_Id as Id
				,G.MtGenerator_Name as GeneratorName
			 from     
			  [dbo].[MtGenerator]  G  
			   Where     
			  G.MtPartyCategory_Id= @pPartyCategoryId    
			  AND ISNULL(G.IsDeleted,0)=0  
ELSE 
				select     
			   mgu.MtGenerationUnit_Id  as Id    
			  ,mgu.MtGenerationUnit_UnitName as GeneratorName    
			 from     
			  [dbo].[MtGenerator]  G  
			  JOIN MtGenerationUnit mgu ON mgu.MtGenerator_Id = G.MtGenerator_Id
			   Where     
			  G.MtPartyCategory_Id= @pPartyCategoryId    
			  AND ISNULL(G.IsDeleted,0)=0  
			  AND ISNULL(mgu.IsDeleted,0)=0  

END ;


    
