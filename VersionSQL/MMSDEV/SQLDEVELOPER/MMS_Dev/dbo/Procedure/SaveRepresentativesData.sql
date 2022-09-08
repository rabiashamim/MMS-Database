/****** Object:  Procedure [dbo].[SaveRepresentativesData]    Committed by VersionSQL https://www.versionsql.com ******/

 CREATE PROCEDURE [dbo].[SaveRepresentativesData]  
  
 AS  
 BEGIN
	declare 
		@p_MtAuthorizedRepresentatives_Id decimal(18,0) = '1',
		@p_MtPartyCategory_Id	varchar(20) = '76',
		@p_MtAuthorizedRepresentatives_Salutation varchar(4),
		@p_MtAuthorizedRepresentatives_Name varchar(50),
		@p_MtAuthorizedRepresentatives_Designation varchar(50),
		@p_MtAuthorizedRepresentatives_AddressLine varchar(200),
		@p_MtAuthorizedRepresentatives_AddressLine2 varchar(200),
		@p_MtAuthorizedRepresentatives_AddressLine3 varchar(200),
		@p_MtAuthorizedRepresentatives_AddressLine4 varchar(200),
		@p_MMtAuthorizedRepresentatives_Country varchar(50),
		@p_MtAuthorizedRepresentatives_Province varchar(50),
		@p_MtAuthorizedRepresentatives_City varchar(50),
		@p_MtAuthorizedRepresentatives_EmailAddress varchar(50),
		@p_MtAuthorizedRepresentatives_PhoneNumber varchar(15),
		@p_MtAuthorizedRepresentatives_PhoneNumber2 varchar(15),
		@p_MtAuthorizedRepresentatives_PhoneAreaCode varchar(5),
		@p_MtAuthorizedRepresentatives_PhoneAreaCode2 varchar(5),
		@p_MtAuthorizedRepresentatives_FaxNumber varchar(15),
		@p_MtAuthorizedRepresentatives_FaxAreaCode varchar(5),
		@p_MtAuthorizedRepresentatives_IsPrimary bit = '1';
	

	
	declare 
		@existingRepresentativesCount int=0,
		@primaryExistsInDbRecord int=0,
		@primaryRepId decimal(18,0),
		@MtAuthorizedRepresentatives_Id decimal(18,2);

	/*step 1: select existing row count related to the party ID*/
	select 
		@existingRepresentativesCount =  count(*) 
	from 
		[dbo].[MtAuthorizedRepresentatives] 
	where 
		MtPartyCategory_Id = @p_MtPartyCategory_Id;

	/*step 2: if there are no existing reps, enter row and set primary bit to 1*/
	if(@existingRepresentativesCount = 0)
	begin
		insert into 
			[dbo].[MtAuthorizedRepresentatives]
				(MtPartyCategory_Id,
				MtAuthorizedRepresentatives_Saluation,
				MtAuthorizedRepresentatives_Name,
				MtAuthorizedRepresentatives_Designation,
				MtAuthorizedRepresentatives_AddressLine,
				--MtAuthorizedRepresentatives_AddressLine2,
				--MtAuthorizedRepresentatives_AddressLine3,
				--MtAuthorizedRepresentatives_AddressLine4,
				--MtAuthorizedRepresentatives_Country,
				MtAuthorizedRepresentatives_Provience,
				MtAuthorizedRepresentatives_City,
				--MtAuthorizedRepresentatives_PhoneAreaCode,
				--MtAuthorizedRepresentatives_PhoneNumber,
				--MtAuthorizedRepresentatives_FaxAreaCode,
				--MtAuthorizedRepresentatives_FaxNumber,
				--MtAuthorizedRepresentatives_PhoneAreaCode2,

				MtAuthorizedRepresentatives_IsPrimary)
		values
				(@p_MtPartyCategory_Id,
				@p_MtAuthorizedRepresentatives_Salutation,
				@p_MtAuthorizedRepresentatives_Name,
				@p_MtAuthorizedRepresentatives_Designation,
				@p_MtAuthorizedRepresentatives_AddressLine,
				@p_MtAuthorizedRepresentatives_Province,
				@p_MtAuthorizedRepresentatives_City,
				'1');

	end

	/*if record exists, update it, else insert into db*/
	else if (@existingRepresentativesCount >0)
	begin
		if exists(select *
				from
					[dbo].[MtAuthorizedRepresentatives] 
				where 
					MtAuthorizedRepresentatives_Id = @p_MtAuthorizedRepresentatives_Id)
		begin
				update  
					[dbo].[MtAuthorizedRepresentatives] 
				set 
					MtPartyCategory_Id = @p_MtPartyCategory_Id,
					MtAuthorizedRepresentatives_Saluation = @p_MtAuthorizedRepresentatives_Salutation,
					MtAuthorizedRepresentatives_Name = @p_MtAuthorizedRepresentatives_Name,
					MtAuthorizedRepresentatives_Designation = @p_MtAuthorizedRepresentatives_Designation,
					MtAuthorizedRepresentatives_AddressLine = @p_MtAuthorizedRepresentatives_AddressLine,
					MtAuthorizedRepresentatives_Provience = @p_MtAuthorizedRepresentatives_Province,
					MtAuthorizedRepresentatives_City = @p_MtAuthorizedRepresentatives_City,
					MtAuthorizedRepresentatives_IsPrimary = @p_MtAuthorizedRepresentatives_IsPrimary
				where
					MtAuthorizedRepresentatives_Id = @p_MtAuthorizedRepresentatives_Id;
		end;
		else
		begin
			insert into 
			[dbo].[MtAuthorizedRepresentatives]
				(MtPartyCategory_Id,
				MtAuthorizedRepresentatives_Saluation,
				MtAuthorizedRepresentatives_Name,
				MtAuthorizedRepresentatives_Designation,
				MtAuthorizedRepresentatives_AddressLine,
				MtAuthorizedRepresentatives_Provience,
				MtAuthorizedRepresentatives_City,
				MtAuthorizedRepresentatives_IsPrimary)
		values
				(@p_MtPartyCategory_Id,
				@p_MtAuthorizedRepresentatives_Salutation,
				@p_MtAuthorizedRepresentatives_Name,
				@p_MtAuthorizedRepresentatives_Designation,
				@p_MtAuthorizedRepresentatives_AddressLine,
				@p_MtAuthorizedRepresentatives_Province,
				@p_MtAuthorizedRepresentatives_City,
				@p_MtAuthorizedRepresentatives_IsPrimary);
		end;

		/*if existing data exists, check if the input primary bit is 1*/
		if(@p_MtAuthorizedRepresentatives_IsPrimary = '1')
		begin
			if exists(select 
							MtAuthorizedRepresentatives_Id
						from 
							[dbo].[MtAuthorizedRepresentatives] 
						where
							MtAuthorizedRepresentatives_IsPrimary = '1')
			begin
				select @primaryRepId = MtAuthorizedRepresentatives_Id
									from 
										[dbo].[MtAuthorizedRepresentatives] 
									where
										MtAuthorizedRepresentatives_IsPrimary = '1'
				if(@primaryRepId <> @p_MtAuthorizedRepresentatives_Id)
				begin
					update 
						[dbo].[MtAuthorizedRepresentatives] 
					set 
						MtAuthorizedRepresentatives_IsPrimary = '1'
					where
						MtAuthorizedRepresentatives_Id = @p_MtAuthorizedRepresentatives_Id;

					update
						[dbo].[MtAuthorizedRepresentatives] 
					set 
						MtAuthorizedRepresentatives_IsPrimary = '0'
					where
						MtAuthorizedRepresentatives_Id = @primaryRepId;
					
				end;
			end;

		end;
	end;
end;
