/****** Object:  Procedure [dbo].[UpdateAddressInfo]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE [dbo].[UpdateAddressInfo] 

  
@MtPartyCategory_Id decimal(18,0)
,@MtPartyAddress_AddressLine varchar(250)
,@MtPartyAddress_AddressLine2 varchar(250) = null
,@MtPartyAddress_AddressLine3 varchar(250) = null
,@MtPartyAddress_AddressLine4 varchar(250) = null
,@MtPartyAddress_Country varchar(50) 
,@MtPartyAddress_province varchar(50)
,@MtPartyAddress_City varchar(50)
,@MtPartyAddress_PhoneAreaCode varchar(5) 
,@MtPartyAddress_PhoneNumber varchar(15)
,@MtPartyAddress_FaxAreaCode varchar(5) = null
,@MtPartyAddress_FaxNumber varchar(15) = null
,@MtPartyAddress_PhoneAreaCode2 varchar(5) = null
,@MtPartyAddress_PhoneNumber2 varchar(15) = null
,@MtPartyAddress_EmailAddress varchar(50)
,@MtPartyAddress_ModifiedBy decimal(18,0)

as  
begin   

DROP TABLE If EXISTS #TempOriginal
DROP TABLE If EXISTS #TempUpdated

select * into #TempOriginal from MtPartyAddress where MtPartyCategory_Id = @MtPartyCategory_Id


update 
	MtPartyAddress 
set 
	MtPartyAddress_AddressLine = @MtPartyAddress_AddressLine
	,MtPartyAddress_AddressLine2 = @MtPartyAddress_AddressLine2
	,MtPartyAddress_AddressLine3 = @MtPartyAddress_AddressLine3
	,MtPartyAddress_AddressLine4 = @MtPartyAddress_AddressLine4
	,MtPartyAddress_Country = @MtPartyAddress_Country
	,MtPartyAddress_province = @MtPartyAddress_province
	,MtPartyAddress_City = @MtPartyAddress_City
	,MtPartyAddress_PhoneAreaCode = @MtPartyAddress_PhoneAreaCode
	,MtPartyAddress_PhoneNumber = @MtPartyAddress_PhoneNumber
	,MtPartyAddress_FaxAreaCode = @MtPartyAddress_FaxAreaCode
	,MtPartyAddress_FaxNumber = @MtPartyAddress_FaxNumber
	,MtPartyAddress_PhoneAreaCode2 = @MtPartyAddress_PhoneAreaCode2
	,MtPartyAddress_PhoneNumber2 = @MtPartyAddress_PhoneNumber2
 	,MtPartyAddress_EmailAddress = @MtPartyAddress_EmailAddress
	,MtPartyAddress_ModifiedBy = @MtPartyAddress_ModifiedBy
	--,MtPartyAddress_ModifiedOn = GETUTCDATE()
where 
	MtPartyCategory_Id = @MtPartyCategory_Id
	 
select * into #TempUpdated from MtPartyAddress where MtPartyCategory_Id = @MtPartyCategory_Id

declare @count int;

select @count =  count(*) from ( 
	select * from #TempOriginal
	EXCEPT
	select * from #TempUpdated
	) as rowsUpdated;

Update 
	MtPartyAddress
set
	MtPartyAddress_ModifiedOn = GETUTCDATE();

select @count as rowsUpdated 
end
