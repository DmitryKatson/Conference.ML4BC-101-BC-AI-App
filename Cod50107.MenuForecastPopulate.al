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
        PrepareForecast(ItemNo);
        LoadTimeSeriesForecast(ItemNo, ForecastDate, PredictionValue, TempTimeSeriesForecast);
        MSSalesForecast.PopulateForecastResult(TempTimeSeriesForecast);
    end;

    procedure PrepareForecast(ItemNo: Code[20])
    var
        MSSalesForecast: Record "MS - Sales Forecast";
    begin
        MSSalesForecast.SetRange("Item No.", ItemNo);
        MSSalesForecast.DeleteAll();
    end;

    local procedure LoadTimeSeriesForecast(ItemNo: Code[20]; ForecastDate: Date; PredictionValue: Decimal; var TempTimeSeriesForecast: Record "Time Series Forecast" temporary)
    begin
        with TempTimeSeriesForecast do begin
            Init();
            "Group ID" := ItemNo;
            "Period Start Date" := ForecastDate;
            Value := PredictionValue;
            Insert();
        end;
    end;
}