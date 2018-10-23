codeunit 50107 "AIR MenuForecastPopulate"
{
    procedure PopulateForecastResult(ItemNo: Code[20]; ForecastDate: Date; PredictionValue: Decimal)
    begin
        DoPopulateForecastResult(ItemNo, ForecastDate, PredictionValue);
    end;

    local procedure DoPopulateForecastResult(ItemNo: Code[20]; ForecastDate: Date; PredictionValue: Decimal)
    var
        TempTimeSeriesForecast: Record "Time Series Forecast" temporary;
        MSSalesForecast: Record "MS - Sales Forecast";
    begin
        LoadTimeSeriesForecast(ItemNo, ForecastDate, PredictionValue, TempTimeSeriesForecast);
        MSSalesForecast.PopulateForecastResult(TempTimeSeriesForecast);
    end;

    local procedure LoadTimeSeriesForecast(ItemNo: Code[20]; ForecastDate: Date; PredictionValue: Decimal; var TempTimeSeriesForecast: Record "Time Series Forecast" temporary)
    begin
        with TempTimeSeriesForecast do begin
            Init();
            "Group ID" := ItemNo;
            //"Period No." := //do here
            "Period Start Date" := ForecastDate;
            Value := PredictionValue;
            Insert();
        end;
    end;

    /*
        LOCAL LoadTimeSeriesForecast()
    FOR LineNo := 1 TO GetOutputLength DO BEGIN
      TempTimeSeriesForecast.INIT;

      EVALUATE(GroupID,GetOutput(LineNo,1));
      TempTimeSeriesForecast."Group ID" := GroupID;

      EVALUATE(PeriodNo,GetOutput(LineNo,2));
      TempTimeSeriesForecast."Period No." := PeriodNo;
      TempTimeSeriesForecast."Period Start Date" :=
        PeriodFormManagement.MoveDateByPeriod(
          TimeSeriesForecastingStartDate,TimeSeriesPeriodType,PeriodNo - TimeSeriesObservationPeriods - 1);
      Value := TempTimeSeriesForecast.Value;
      TypeHelper.Evaluate(Value,GetOutput(LineNo,3),'','');
      TempTimeSeriesForecast.Value := Value;

      Value := TempTimeSeriesForecast.Delta;
      TypeHelper.Evaluate(Value,GetOutput(LineNo,4),'','');
      TempTimeSeriesForecast.Delta := Value;
      IF TempTimeSeriesForecast.Value <> 0 THEN
        TempTimeSeriesForecast."Delta %" := ABS(TempTimeSeriesForecast.Delta / TempTimeSeriesForecast.Value) * 100;

      TempTimeSeriesForecast.INSERT;
    END;
    */


}