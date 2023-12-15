/****** Object:  Procedure [dbo].[ImportSDXPDataFromAPI]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE  PROCEDURE dbo.ImportSDXPDataFromAPI
AS
BEGIN
   DECLARE @Object AS INT;
    DECLARE @json TABLE (Json_Table NVARCHAR(MAX));

    -- Create the XMLHTTP object
    EXEC sp_OACREATE 'MSXML2.ServerXMLHttp', @Object OUT;


    -- Open connection and send request
    EXEC sp_OAMethod @Object, 'Open', NULL, 'POST', 'https://sdxp.ntdc.gov.pk/api/sdxp/marginal_price_report', 'false';
	EXEC sp_OAMethod @Object, 'SETRequestHeader', null, 'Content-Type', 'application/x-www-form-urlencoded';
	EXEC sp_OAMethod @Object, 'SETRequestHeader', NULL, 'Authorization', 'Bearer H3-GzLd_uGlZxwMcxObcWHmfRwRWaN8tVAGguJS4w0rCtBgDlaWHQ98USSoAotCcqx_dOhqPpcZUMm9Opam-k-x8he2BCMGnQwSwH9DiXRWtGvc-IYbI4fp1WEkL450tg15wx3ZpnAxhe51upGv7e7VmhgwSLP56i0gfhf25mk5krfUcIbF-iuDoYKXeStZkq5mRPj9CV9uVvxkzBEfpk-vlNwl97P8VVBh1jgrOqBKKBS8EgJ6OaXtJLrVfxcZprXngTcNrdsb0-tGGzFE6__2f4O48f3yloTyahDWT_89rfCl91u0-fNVn9dNldNYDwKGbZKlUnIHuAfzRnCvdimFSFbSpNyo46RzL6NKVm4g';
    
    EXEC sp_OAMethod @Object, 'Send', null, 'start_date=2023-10-01&end_date=2023-10-31&vendor_id=%&ipp_category=20';

    -- Insert API response into table variable
	
    INSERT into @json (Json_Table) exec sp_OAGetProperty @Object, 'responseText';
	CREATE TABLE #TempTable(
    Id decimal(18,0) IDENTITY(1,1) PRIMARY KEY,
    Date nvarchar(50),
    Hour int,
    MARGINAL_PRICE float
	);
	INSERT INTO #TempTable(Date,Hour,MARGINAL_PRICE) 
	SELECT [Date], Hour, MARGINAL_PRICE
	FROM OPENJSON((SELECT * FROM @json))
	WITH
	(
		[Date] NVARCHAR(50),
		Hour INT,
		MARGINAL_PRICE FLOAT
	);

-- Display the data in the temporary table
	SELECT * FROM #TempTable;
    -- Select the result
    SELECT * FROM @json;

    -- Clean up
    EXEC sp_OADestroy @Object;
END
