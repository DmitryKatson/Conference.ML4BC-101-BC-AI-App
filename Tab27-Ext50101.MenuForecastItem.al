tableextension 50101 "AIR MenuForecastItem" extends Item //27
{
    procedure UpdateRestaurantMenuForecastForAllMenuItems()
    var
        MFCalculate: Codeunit "AIR MenuForecast Calculate";
    begin
        MFCalculate.UpdateRestaurantMenuForecastForAllMenuItems();
    end;

    procedure UpdateRestaurantMenuForecast()
    var
        MFCalculate: Codeunit "AIR MenuForecast Calculate";
    begin
        MFCalculate.UpdateRestaurantMenuForecast(Rec);
    end;

    procedure GetCurrentInventory(): Decimal
    begin
        CalcFields(Inventory);
        Exit(Inventory)
    end;

}