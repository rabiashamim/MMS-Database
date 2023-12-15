/****** Object:  Procedure [dbo].[BMEStepsOutputView_BK_12_12_22]    Committed by VersionSQL https://www.versionsql.com ******/

-- [dbo].[BMEStepsOutputView] 25,8
-- [dbo].[BMEStepsOutputView] 3,2.
-- [dbo].[BMEStepsOutputView] 20,10

CREATE PROCEDURE dbo.BMEStepsOutputView_BK_12_12_22
    @pSettlementProcessId int,
    @pStepId decimal(4, 1)
AS
BEGIN

    DECLARE @vSrProcessDef_ID DECIMAL(18, 0);
    SELECT @vSrProcessDef_ID = SrProcessDef_ID
    FROM MtStatementProcess
    WHERE MtStatementProcess_ID = @pSettlementProcessId
          AND ISNULL(MtStatementProcess_IsDeleted, 0) = 0

    --**************
    if (@pStepId = 1)
    BEGIN
        select ROW_NUMBER() OVER (Order by BmeStatementData_Id) as [Sr],
               BmeStatementData_Month as [Month],
               BmeStatementData_Day as [Day],
               BmeStatementData_Hour - 1 as [Hour],
               BmeStatementData_CdpId as [CDP-ID],
               BmeStatementData_FromPartyRegisteration_Name as [Connected From],
               BmeStatementData_ToPartyRegisteration_Name as [Connected To],
               BmeStatementData_FromPartyRegisteration_Id as [Connected From Id],
               BmeStatementData_ToPartyRegisteration_Id as [Connected To Id],
               BmeStatementData_LineVoltage as [Line Voltage (kV)],
               BmeStatementData_IncEnergyImport as [Energy Import (kWh)],
               BmeStatementData_IncEnergyExport as [Energy Export (kWh)]
        from BmeStatementDataCdpHourly_SettlementProcess
        where --BmeStatementData_Year=2021 and BmeStatementData_Month=11 and 
            BmeStatementData_StatementProcessId = @pSettlementProcessId
        Order by BmeStatementData_Month,
                 BmeStatementData_Day,
                 BmeStatementData_Hour,
                 BmeStatementData_CdpId;
    END


    --------------------------------------------------------------
    ELSE if (@pStepId = 2)
    BEGIN
        -----------  2.1
        select ROW_NUMBER() OVER (Order by Lu_DistLosses_Id) as [Sr],
               Lu_DistLosses_MP_Name as [Entity Name],
               MtPartyRegisteration_Id as [Entity Id],
               Lu_DistLosses_LineVoltage as [Line Voltage (kV)],
               Lu_DistLosses_Factor as [Factor (%)]
        from Lu_DistLosses
        Order by MtPartyRegisteration_Id

        ---------- 2.2
        select ROW_NUMBER() OVER (Order by BmeStatementData_Id) as [Sr],
               BmeStatementData_Month as [Month],
               BmeStatementData_Day as [Day],
               BmeStatementData_Hour - 1 as [Hour],
               BmeStatementData_CdpId as [CDP-ID],
               BmeStatementData_FromPartyRegisteration_Name as [Connected From],
               BmeStatementData_ToPartyRegisteration_Name as [Connected To],
               BmeStatementData_FromPartyRegisteration_Id as [Connected From Id],
               BmeStatementData_ToPartyRegisteration_Id as [Connected To Id],
               BmeStatementData_LineVoltage as [Line Voltage (kV)],
               BmeStatementData_IncEnergyImport as [Energy Import (kWh)],
               BmeStatementData_IncEnergyExport as [Energy Export (kWh)],
               BmeStatementData_AdjustedEnergyImport as [Adjusted Energy Import (kWh)],
               BmeStatementData_AdjustedEnergyExport as [Adjusted Energy Export (kWh)]
        from BmeStatementDataCdpHourly_SettlementProcess
        where BmeStatementData_StatementProcessId = @pSettlementProcessId
        Order by BmeStatementData_Month,
                 BmeStatementData_Day,
                 BmeStatementData_Hour,
                 BmeStatementData_CdpId;
    END
    --------------------------------------------------------------
    ELSE if (@pStepId = 3)
    BEGIN

        --------------- 3.1
        select ROW_NUMBER() OVER (Order by BmeStatementData_Id) as [Sr],
               BmeStatementData_Month as [Month],
               BmeStatementData_Day as [Day],
               BmeStatementData_Hour - 1 as [Hour],
               BmeStatementData_PartyRegisteration_Id as [TSP-ID],
               BmeStatementData_PartyName as [TSP-Name],
               BmeStatementData_AdjustedEnergyImport as [Adjusted Energy Import (kWh)],
               BmeStatementData_AdjustedEnergyExport as [Adjusted Energy Export (kWh)],
               BmeStatementData_TransmissionLosses as [Transmission Loss (MWh)]
        from BmeStatementDataTspHourly_SettlementProcess
        where BmeStatementData_StatementProcessId = @pSettlementProcessId
        Order by BmeStatementData_Month,
                 BmeStatementData_Day,
                 BmeStatementData_Hour,
                 BmeStatementData_PartyRegisteration_Id;

        --------------- 3.2 
        --select ROW_NUMBER() OVER(Order by BmeStatementData_Month, BmeStatementData_Day, BmeStatementData_Hour) as [Sr],  
        --BmeStatementData_Month as [Month], 
        --BmeStatementData_Day as [Day], 
        --BmeStatementData_Hour as [Hour] ,
        --Sum(BmeStatementData_AdjustedEnergyImport) as [Adjusted Energy Import (kWh)],
        --Sum(BmeStatementData_AdjustedEnergyExport) as [Adjusted Energy Export (kWh)],
        --Sum(BmeStatementData_TransmissionLosses) as [Transmission Loss (MWh)]

        --from BmeStatementDataTspHourly_SettlementProcess where BmeStatementData_StatementProcessId=@pSettlementProcessId
        --Group by BmeStatementData_Month, BmeStatementData_Day, BmeStatementData_Hour
        --Order by BmeStatementData_Month, BmeStatementData_Day, BmeStatementData_Hour;


        select ROW_NUMBER() OVER (Order by BmeStatementData_Month,
                                           BmeStatementData_Day,
                                           BmeStatementData_Hour
                                 ) as [Sr],
               BmeStatementData_Month as [Month],
               BmeStatementData_Day as [Day],
               BmeStatementData_Hour - 1 as [Hour],
               Sum(BmeStatementData_TransmissionLosses) as [Transmission Loss (MWh)]
        from BmeStatementDataHourly
        where BmeStatementData_StatementProcessId = @pSettlementProcessId
        Group by BmeStatementData_Month,
                 BmeStatementData_Day,
                 BmeStatementData_Hour
        Order by BmeStatementData_Month,
                 BmeStatementData_Day,
                 BmeStatementData_Hour;


        --------------- 3.3 
        select ROW_NUMBER() OVER (Order by BmeStatementData_Id) as [Sr],
               BmeStatementData_Month as [Month],
               BmeStatementData_Day as [Day],
               BmeStatementData_Hour - 1 as [Hour],
               BmeStatementData_DemandedEnergy as [Total Demand (MWh)]
        from BmeStatementDataHourly_SettlementProcess
        where BmeStatementData_StatementProcessId = @pSettlementProcessId
        Order by BmeStatementData_Month,
                 BmeStatementData_Day,
                 BmeStatementData_Hour;

    END
    --------------------------------------------------------------
    ELSE if (@pStepId = 4)
    BEGIN
        select ROW_NUMBER() OVER (Order by BmeStatementData_Id) as [Sr],
               BmeStatementData_Month as [Month],
               BmeStatementData_Day as [Day],
               BmeStatementData_Hour - 1 as [Hour],
               BmeStatementData_TransmissionLosses as [Transmission Loss (MWh)],
               BmeStatementData_DemandedEnergy as [Total Demand (MWh)],
               BmeStatementData_UpliftTransmissionLosses as [Uplift Transmission Loss]
        from BmeStatementDataHourly_SettlementProcess
        where BmeStatementData_StatementProcessId = @pSettlementProcessId
        Order by BmeStatementData_Month,
                 BmeStatementData_Day,
                 BmeStatementData_Hour;

        EXEC [dbo].[BME_GenerationEnergyInfo] @pSettlementProcessId;
        ---4.3 for Generator and Generation Unit wise energy with availabilities

        EXEC BME_GenerationEnergyAndAvailabilityOutputs @pSettlementProcessId
    END
    --------------------------------------------------------------
    ELSE if (@pStepId = 5)
    BEGIN
        select ROW_NUMBER() OVER (Order by BmeStatementData_Id) as [Sr],
               BmeStatementData_Month as [Month],
               BmeStatementData_Day as [Day],
               BmeStatementData_Hour - 1 as [Hour],
               BmeStatementData_PartyName as [MP Name],
               BmeStatementData_PartyRegisteration_Id as [MP ID],
               BmeStatementData_ActualEnergy as [Hourly Metered Energy (Act_E) (kWh)],
               BmeStatementData_ActualEnergy_Metered as [Hourly Inc Metered Energy (Act_E) (kWh)]
        from BmeStatementDataMpHourly_SettlementProcess
        where BmeStatementData_StatementProcessId = @pSettlementProcessId
        Order by BmeStatementData_Month,
                 BmeStatementData_Day,
                 BmeStatementData_Hour,
                 BmeStatementData_PartyRegisteration_Id;

    END
    --------------------------------------------------------------
    ELSE if (@pStepId = 6)
    BEGIN
        ------------- 6.1
        select ROW_NUMBER() OVER (Order by BmeStatementData_Id) as [Sr],
               BmeStatementData_Month as [Month],
               BmeStatementData_Day as [Day],
               BmeStatementData_Hour - 1 as [Hour],
               BmeStatementData_PartyName as [MP Name],
               BmeStatementData_PartyRegisteration_Id as [MP ID],
               BmeStatementData_ActualEnergy as [Hourly Metered Energy (Act_E) (kWh)],
               BmeStatementData_ActualEnergy_Metered as [Hourly Inc Metered Energy (Act_E) (kWh)],
               BmeStatementData_EnergySuppliedActual as [Hourly  Energy Supplied (ES_A) (kWh)]
        from BmeStatementDataMpHourly_SettlementProcess
        where BmeStatementData_StatementProcessId = @pSettlementProcessId
        Order by BmeStatementData_Month,
                 BmeStatementData_Day,
                 BmeStatementData_Hour,
                 BmeStatementData_PartyRegisteration_Id;

        ------------- 6.2
        select ROW_NUMBER() OVER (Order by BmeStatementData_Id) as [Sr],
               BmeStatementData_Month as [Month],
               BmeStatementData_Day as [Day],
               BmeStatementData_Hour - 1 as [Hour],
               BmeStatementData_PartyName as [MP Name],
               BmeStatementData_PartyRegisteration_Id as [MP ID],
               BmeStatementData_ActualEnergy as [Hourly Metered Energy (Act_E) (kWh)],
               BmeStatementData_ActualEnergy_Metered as [Hourly Inc Metered Energy (Act_E) (kWh)],
               BmeStatementData_EnergySuppliedActual as [Hourly  Energy Supplied (ES_A (kWh)],
               BmeStatementData_EnergySuppliedGenerated as [Hourly  Generation (ES_G) (kWh)]
        from BmeStatementDataMpHourly_SettlementProcess
        where BmeStatementData_StatementProcessId = @pSettlementProcessId
        Order by BmeStatementData_Month,
                 BmeStatementData_Day,
                 BmeStatementData_Hour,
                 BmeStatementData_PartyRegisteration_Id;

        ------------- 6.3
        select ROW_NUMBER() OVER (Order by BmeStatementData_Id) as [Sr],
               BmeStatementData_Month as [Month],
               BmeStatementData_Day as [Day],
               BmeStatementData_Hour - 1 as [Hour],
               BmeStatementData_PartyName as [MP Name],
               BmeStatementData_PartyRegisteration_Id as [MP ID],
               BmeStatementData_ActualEnergy as [Hourly Metered Energy (Act_E) (kWh)],
               BmeStatementData_ActualEnergy_Metered as [Hourly Inc Metered Energy (Act_E) (kWh)],
               BmeStatementData_EnergySuppliedActual as [Hourly  Energy Supplied (ES_A) (kWh)],
               BmeStatementData_EnergySuppliedGenerated as [Hourly  Generation (ES_G) (kWh)],
               BmeStatementData_EnergySuppliedImported as [Hourly Imported (ES_I) (kWh)]
        from BmeStatementDataMpHourly_SettlementProcess
        where BmeStatementData_StatementProcessId = @pSettlementProcessId
        Order by BmeStatementData_Month,
                 BmeStatementData_Day,
                 BmeStatementData_Hour,
                 BmeStatementData_PartyRegisteration_Id;

    END
    --------------------------------------------------------------
    ELSE if (@pStepId = 7)
    BEGIN
        ----------	7.1
        select ROW_NUMBER() OVER (Order by BmeStatementData_Id) as [Sr],
               BmeStatementData_ContractId as [Contract ID],
               Convert(date, BmeStatementData_NtdcDateTime) as [Date],
               BmeStatementData_Hour - 1 as [Hour],
               BmeStatementData_SellerPartyRegisteration_Name as [Seller Name],
               BmeStatementData_BuyerPartyRegisteration_Name as [Buyer Name],
               BmeStatementData_SellerPartyRegisteration_Id as [Seller Id],
               BmeStatementData_BuyerPartyRegisteration_Id as [Buyer Id],
               BmeStatementData_ContractType as [Contract Type],
               BmeStatementData_CdpId as [Relevant CDPs],
               BmeStatementData_Percentage as [Percentage],
               BmeStatementData_ContractedQuantity as [Contracted Quantity (kWh)],
               BmeStatementData_CapQuantity as [Contract Cap],
               BmeStatementData_AncillaryServices as [Ancillary Services]
        from BmeStatementDataCdpContractHourly_SettlementProcess
        where BmeStatementData_StatementProcessId = @pSettlementProcessId
        Order by BmeStatementData_ContractId,
                 BmeStatementData_Day,
                 BmeStatementData_Hour,
                 BmeStatementData_CdpId;

        -------------		7.2
        Drop table if EXISTS #temp7_2;
        select Distinct
            BmeStatementData_Month as [Month],
            BmeStatementData_Day as [Day],
            BmeStatementData_Hour - 1 as [Hour],
            BmeStatementData_CAPLegacy as [CAP]
        into #temp7_2
        from BmeStatementDataHourly_SettlementProcess
        where BmeStatementData_StatementProcessId = @pSettlementProcessId
        Order by BmeStatementData_Month,
                 BmeStatementData_Day,
                 [HOUR]; -- updated Ammama


        select ROW_NUMBER() OVER (Order by Month, Day, Hour) as [Sr],
               *
        from #temp7_2

        ---------------	7.3
        select ROW_NUMBER() OVER (Order by BmeStatementData_Id) as [Sr],
               BmeStatementData_Month as [Month],
               BmeStatementData_Day as [Day],
               BmeStatementData_Hour - 1 as [Hour],
               BmeStatementData_PartyName as [MP Name],
               BmeStatementData_PartyRegisteration_Id as [MP ID],
               BmeStatementData_ActualEnergy as [Hourly Metered Energy (Act_E) (kWh)],
               BmeStatementData_ActualEnergy_Metered as [Hourly Inc Metered Energy (Act_E) (kWh)],
               BmeStatementData_EnergySuppliedActual as [Hourly  Energy Supplied (ES_A) (kWh)],
               BmeStatementData_EnergySuppliedGenerated as [Hourly  Generation (ES_G) (kWh)],
               BmeStatementData_EnergySuppliedImported as [Hourly Imported Energy (ES_I) (kWh)],
               BmeStatementData_EnergyTradedBought as [ET_Bought (kWh)],
               BmeStatementData_EnergyTradedSold as [ET_Sold (kWh)],
               BmeStatementData_EnergyTraded as [Hourly Contracted Energy (ET) (kWh)]
        from BmeStatementDataMpHourly_SettlementProcess
        where BmeStatementData_StatementProcessId = @pSettlementProcessId
        Order by BmeStatementData_Month,
                 BmeStatementData_Day,
                 BmeStatementData_Hour,
                 BmeStatementData_PartyRegisteration_Id;



        ---------------	7.4
        SELECT BmeStatementData_NtdcDateTime AS [DATE TIME],
               BmeStatementData_PartyRegisteration_Id [Party Id],
               BmeStatementData_PartyName [Party Name],
               BmeStatementData_CAPLegacy [CAP]
        FROM BmeStatementDataMpHourly_SettlementProcess
        WHERE BmeStatementData_StatementProcessId = @pSettlementProcessId
              AND BmeStatementData_PartyRegisteration_Id <> 1
        Order by BmeStatementData_Month,
                 BmeStatementData_Day,
                 BmeStatementData_Hour,
                 BmeStatementData_PartyRegisteration_Id;
    END
    --------------------------------------------------------------
    ELSE if (@pStepId = 8)
    BEGIN
        ---------------	8.1
        select ROW_NUMBER() OVER (Order by BmeStatementData_Id) as [Sr],
               BmeStatementData_Month as [Month],
               BmeStatementData_Day as [Day],
               BmeStatementData_Hour - 1 as [Hour],
               BmeStatementData_PartyName as [MP Name],
               BmeStatementData_PartyRegisteration_Id as [MP ID],
               BmeStatementData_ActualEnergy as [Hourly Metered Energy (Act_E) (kWh)],
               BmeStatementData_ActualEnergy_Metered as [Hourly Inc Metered Energy (Act_E) (kWh)],
               BmeStatementData_EnergySuppliedActual as [Hourly  Energy Supplied (ES_A) (kWh)],
               BmeStatementData_EnergySuppliedGenerated as [Hourly  Generation (ES_G) (kWh)],
               BmeStatementData_EnergySuppliedImported as [Hourly Imported Energy (ES_I) (kWh)],
               BmeStatementData_EnergyTraded as [Hourly Contracted Energy (ET) (kWh)],
               BmeStatementData_Imbalance as [Energy Imbalance (kWh)]
        from BmeStatementDataMpHourly_SettlementProcess
        where BmeStatementData_StatementProcessId = @pSettlementProcessId
        Order by BmeStatementData_Month,
                 BmeStatementData_Day,
                 BmeStatementData_Hour,
                 BmeStatementData_PartyRegisteration_Id;


        ---------------	8.2
        select ROW_NUMBER() OVER (Order by BmeStatementData_Id) as [Sr],
               BmeStatementData_Month as [Month],
               BmeStatementData_Day as [Day],
               BmeStatementData_Hour - 1 as [Hour],
               BmeStatementData_PartyName as [MP Name],
               BmeStatementData_PartyRegisteration_Id as [MP ID],
               BmeStatementData_ActualEnergy as [Hourly Metered Energy (Act_E) (kWh)],
               BmeStatementData_ActualEnergy_Metered as [Hourly Inc Metered Energy (Act_E) (kWh)],
               BmeStatementData_EnergySuppliedActual as [Hourly  Energy Supplied (ES_A (kWh)],
               BmeStatementData_EnergySuppliedGenerated as [Hourly  Generation (ES_G)],
               BmeStatementData_EnergySuppliedImported as [Hourly Imported Energy (ES_I (kWh))],
               BmeStatementData_EnergyTraded as [Hourly Contracted Energy (ET) (kWh)],
               BmeStatementData_Imbalance as [Energy Imbalance (kWh)],
               BmeStatementData_MarginalPrice as [Marginal Price (PKR)]
        from BmeStatementDataMpHourly_SettlementProcess
        where BmeStatementData_StatementProcessId = @pSettlementProcessId
        Order by BmeStatementData_Month,
                 BmeStatementData_Day,
                 BmeStatementData_Hour,
                 BmeStatementData_PartyRegisteration_Id;

        ---------------	8.3


        select ROW_NUMBER() OVER (Order by BmeStatementData_Month,
                                           BmeStatementData_PartyRegisteration_Id,
                                           BmeStatementData_Day,
                                           BmeStatementData_Hour
                                 ) as [Sr],
               BmeStatementData_Month as [Month],
               BmeStatementData_Day as [Day],
               BmeStatementData_Hour - 1 as [Hour],
               BmeStatementData_PartyName as [MP Name],
               BmeStatementData_PartyRegisteration_Id as [MP ID],
               BmeStatementData_ActualEnergy_Metered as [Hourly Inc Metered Energy (Act_E) (kWh)],
               BmeStatementData_ActualEnergy as [Hourly Adjusted Energy (Act_E) (kWh)],
               BmeStatementData_EnergySuppliedActual as [Hourly  Energy Supplied (ES_A (kWh)],
               BmeStatementData_EnergySuppliedGenerated as [Hourly  Generation (ES_G)],
               BmeStatementData_EnergySuppliedImported as [Hourly Imported Energy (ES_I (kWh))],
               BmeStatementData_CAPLegacy AS [CAP],
               BmeStatementData_EnergyTradedBought as [ET_Bought (kWh)],
               BmeStatementData_EnergyTradedSold as [ET_Sold (kWh)],
               BmeStatementData_EnergyTraded as [Hourly Contracted Energy (ET) (kWh)],
               BmeStatementData_Imbalance as [Energy Imbalance (kWh)],
               BmeStatementData_MarginalPrice AS [Marginal Price],
               BmeStatementData_ImbalanceCharges as [Imbalance Charges (PKR)]
        from BmeStatementDataMpHourly_SettlementProcess
        where BmeStatementData_StatementProcessId = @pSettlementProcessId
        Order by BmeStatementData_Month,
                 BmeStatementData_PartyRegisteration_Id,
                 BmeStatementData_Day,
                 BmeStatementData_Hour;

    END
    --------------------------------------------------------------
    ELSE if (@pStepId = 9)
    BEGIN
        -----------	9.2
        select ROW_NUMBER() OVER (Order by BmeStatementData_Id) as [Sr],
               BmeStatementData_Month as [Month],
               BmeStatementData_PartyName as [MP Name],
               BmeStatementData_PartyRegisteration_Id as [MP ID],
               BmeStatementData_SettlementOfLegacy as [Settlement of Legacy (PKR)]
        from BmeStatementDataMpMonthly_SettlementProcess
        where BmeStatementData_StatementProcessId = @pSettlementProcessId
        Order by BmeStatementData_PartyRegisteration_Id;

    END
    --------------------------------------------------------------
    ELSE if (@pStepId = 10)
    BEGIN
        -----------------10.1

        select ROW_NUMBER() OVER (Order by BmeStatementData_Id) as [Sr],
               MPM.BmeStatementData_Month as [Month],
               MPM.BmeStatementData_PartyName as [MP Name],
               MPM.BmeStatementData_PartyRegisteration_Id as [MP ID],
               (
                   select SUM(MPH.BmeStatementData_ActualEnergy_Metered)
                   from BmeStatementDataMpHourly_SettlementProcess MPH
                   where MPH.BmeStatementData_StatementProcessId = @pSettlementProcessId
                         and MPH.BmeStatementData_PartyRegisteration_Id = MPM.BmeStatementData_PartyRegisteration_Id
                         and MPH.BmeStatementData_Month = MPM.BmeStatementData_Month
                   GROUP by MPH.BmeStatementData_PartyRegisteration_Id,
                            MPH.BmeStatementData_Month
               ) as [Actual Energy (kW)],
               (
                   select SUM(MPH.BmeStatementData_ActualEnergy)
                   from BmeStatementDataMpHourly_SettlementProcess MPH
                   where MPH.BmeStatementData_StatementProcessId = @pSettlementProcessId
                         and MPH.BmeStatementData_PartyRegisteration_Id = MPM.BmeStatementData_PartyRegisteration_Id
                         and MPH.BmeStatementData_Month = MPM.BmeStatementData_Month
                   GROUP by MPH.BmeStatementData_PartyRegisteration_Id,
                            MPH.BmeStatementData_Month
               ) as [Adjusted Energy (kW)],
               (
                   select SUM(MPH.BmeStatementData_EnergySuppliedActual)
                   from BmeStatementDataMpHourly_SettlementProcess MPH
                   where MPH.BmeStatementData_StatementProcessId = @pSettlementProcessId
                         and MPH.BmeStatementData_PartyRegisteration_Id = MPM.BmeStatementData_PartyRegisteration_Id
                         and MPH.BmeStatementData_Month = MPM.BmeStatementData_Month
                   GROUP by MPH.BmeStatementData_PartyRegisteration_Id,
                            MPH.BmeStatementData_Month
               ) as [Energy Supplied (kW)],
               MPM.BmeStatementData_SettlementOfLegacy as [Settlement of Legacy (PKR)],
               MPM.BmeStatementData_ImbalanceCharges as [Imbalance Charges (PKR)],
               MPM.BmeStatementData_AmountPayableReceivable as [Amount Payable / Amount Receivable (PKR)]
        into #tempStep10
        from BmeStatementDataMpMonthly_SettlementProcess MPM
        where MPM.BmeStatementData_StatementProcessId = @pSettlementProcessId
        --and MPM.BmeStatementData_PartyRegisteration_Id<>1115
        Order by BmeStatementData_PartyRegisteration_Id;


        Insert into #tempStep10
        (
            [Month],
            [MP Name],
            [Amount Payable / Amount Receivable (PKR)],
            [Imbalance Charges (PKR)]
        )
        Values
        (   '',
            'Total',
            (
                select sum([Amount Payable / Amount Receivable (PKR)]) from #tempStep10
            ),
            (
                select sum([Imbalance Charges (PKR)]) from #tempStep10
            )
        )

        select [Sr],
               case
                   WHEN [Month] = 0 THEN
                       NULL
                   else
                       [Month]
               end as [Month],
               [MP Name],
               [MP ID],
               [Actual Energy (kW)] as [Actual Energy (kW)],
               [Adjusted Energy (kW)] AS [Adjusted Energy (kW)],
               [Energy Supplied (kW)],
               [Settlement of Legacy (PKR)],
               [Imbalance Charges (PKR)],
               [Amount Payable / Amount Receivable (PKR)]
        from #tempStep10
        order by case
                     when [Sr] is null then
                         1
                     else
                         0
                 end,
                 [Sr]

    END
    ELSE if (@pStepId = 11 AND @vSrProcessDef_ID = 7)
    BEGIN

        Declare @vPredecessorId as decimal(18, 0)

        select @vPredecessorId = [dbo].[GetESSAdjustmentPredecessorStatementId](@pSettlementProcessId);

        select ROW_NUMBER() OVER (Order by MPM.BmeStatementData_Id) as [Sr],
               MPM.BmeStatementData_Month as [Month],
               MPM.BmeStatementData_PartyName as [MP Name],
               MPM.BmeStatementData_PartyRegisteration_Id as [MP ID],
               (
                   select SUM(MPH.BmeStatementData_ActualEnergy)
                   from BmeStatementDataMpHourly_SettlementProcess MPH
                   where MPH.BmeStatementData_StatementProcessId = @pSettlementProcessId
                         and MPH.BmeStatementData_PartyRegisteration_Id = MPM.BmeStatementData_PartyRegisteration_Id
                         and MPH.BmeStatementData_Month = MPM.BmeStatementData_Month
                   GROUP by MPH.BmeStatementData_PartyRegisteration_Id,
                            MPH.BmeStatementData_Month
               ) as [Actual Energy],
               (
                   select SUM(MPH.BmeStatementData_ActualEnergy_Metered)
                   from BmeStatementDataMpHourly_SettlementProcess MPH
                   where MPH.BmeStatementData_StatementProcessId = @pSettlementProcessId
                         and MPH.BmeStatementData_PartyRegisteration_Id = MPM.BmeStatementData_PartyRegisteration_Id
                         and MPH.BmeStatementData_Month = MPM.BmeStatementData_Month
                   GROUP by MPH.BmeStatementData_PartyRegisteration_Id,
                            MPH.BmeStatementData_Month
               ) as [Inc Actual Energy],
               MPM.BmeStatementData_SettlementOfLegacy as [Settlement of Legacy (PKR)],
               MPM.BmeStatementData_ImbalanceCharges as [Imbalance Charges (PKR)],
               MPM_Previous.BmeStatementData_AmountPayableReceivable as [Previous Month Amount Payable / Amount Receivable (PKR)],
               MPM.BmeStatementData_AmountPayableReceivable as [Amount Payable / Amount Receivable (PKR)],
               MPM.BmeStatementData_ESSAdjustment as [ESS Adjustment (PKR)]
        into #tempStep11
        from BmeStatementDataMpMonthly_SettlementProcess MPM
            Join BmeStatementDataMpMonthly_SettlementProcess MPM_Previous
                on MPM.BmeStatementData_PartyRegisteration_Id = MPM_Previous.BmeStatementData_PartyRegisteration_Id
        where MPM.BmeStatementData_StatementProcessId = @pSettlementProcessId
              and MPM_Previous.BmeStatementData_StatementProcessId = @vPredecessorId
        --and MPM.BmeStatementData_PartyRegisteration_Id<>1115
        Order by MPM.BmeStatementData_PartyRegisteration_Id;

        Insert into #tempStep11
        (
            [MP Name],
            [Month],
            [Previous Month Amount Payable / Amount Receivable (PKR)],
            [Amount Payable / Amount Receivable (PKR)],
            [ESS Adjustment (PKR)],
            [Imbalance Charges (PKR)]
        )
        Values
        (   'Total',
            '',
            (
                select sum([Previous Month Amount Payable / Amount Receivable (PKR)])
                from #tempStep11
            ),
            (
                select sum([Amount Payable / Amount Receivable (PKR)]) from #tempStep11
            ),
            (
                select sum([ESS Adjustment (PKR)]) from #tempStep11
            ),
            (
                select sum([Imbalance Charges (PKR)]) from #tempStep11
            )
        )

        Declare @vPredecessorMonthName as NVARCHAR(MAX);
        select @vPredecessorMonthName = [dbo].[GetMonthNameFromMtStatementProcessId](@vPredecessorId)

        declare @query nvarchar(max);

        set @query
            = 'select
	[Sr]	,case WHEN [Month]=0 THEN NULL else [Month] end	as [Month]	,[MP Name]	,[MP ID],	[Actual Energy] as [Actual Energy (kW)],[Settlement of Legacy (PKR)],[Imbalance Charges (PKR)],[Amount Payable / Amount Receivable (PKR)]	,[Previous Month Amount Payable / Amount Receivable (PKR)] as ['
              + @vPredecessorMonthName
              + '],	[ESS Adjustment (PKR)] from #tempStep11 order by case when [Sr] is null then 1 else 0 end, [Sr]
'       ;
        exec (@query);
    END
    ELSE if (
                (
                    @pStepId = 11
                    AND @vSrProcessDef_ID IN ( 1, 4 )
                )
                OR (
                       @pStepId = 12
                       AND @vSrProcessDef_ID = 7
                   )
            )
    BEGIN
        EXECUTE BME_PostValidationReport @pSettlementProcessId

    END
END
