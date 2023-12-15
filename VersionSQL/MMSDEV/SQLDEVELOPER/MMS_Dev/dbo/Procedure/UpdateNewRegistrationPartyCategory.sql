/****** Object:  Procedure [dbo].[UpdateNewRegistrationPartyCategory]    Committed by VersionSQL https://www.versionsql.com ******/

CREATE PROCEDURE UpdateNewRegistrationPartyCategory(@pPartyRegistration_Id INT,
                                                   @pLuStatus_Code
VARCHAR(4))
AS
  BEGIN
      UPDATE mtpartycategory
      SET    lustatus_code = @pLuStatus_Code
      WHERE  mtpartycategory_id = (SELECT TOP 1 mpc.mtpartycategory_id
                                   FROM   mtpartycategory mpc
                                   WHERE
             mtpartyregisteration_id = @pPartyRegistration_Id
             AND Isnull(mpc.isdeleted, 0) = 0)
             AND Isnull(isdeleted, 0) = 0;
  END 
