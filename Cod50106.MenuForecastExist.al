codeunit 50106 "AIR MenuForecast Exist"
{
    procedure HasSalesForecast(Item: Record Item): Boolean
    begin
        exit(HasMenuSalesForecast(Item));
    end;

    local procedure HasMenuSalesForecast(Item: Record Item): Boolean
    var
        MFSetup: Record "AIR Menu Forecast Setup";
        MSSalesForecast: Record "MS - Sales Forecast";
        MSSalesForecastParameter: Record "MS - Sales Forecast Parameter";
        LastValidDate: Date;
    begin
        if not MFSetup.IsMenuForecastProperlyConfigured() then
            exit(false);

        MSSalesForecast.SetRange("Item No.", Item."No.");
        MSSalesForecast.SetRange("Forecast Data", MSSalesForecast."Forecast Data"::Result);
        if not MSSalesForecast.FindFirst() then
            exit(false);

        // check if forecast expired
        if MSSalesForecastParameter."Last Updated" <> 0DT then begin
            LastValidDate := CalcDate('<7D>',
              DT2Date(MSSalesForecastParameter."Last Updated"));
            if LastValidDate <= WorkDate() then
                exit(false);
        end;

        exit(true);
    end;

}