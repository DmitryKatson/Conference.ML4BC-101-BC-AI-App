codeunit 50103 "AIR MenuForecast Calculate"
{
    procedure UpdateRestaurantMenuForecastForAllMenuItems()
    begin
        DoUpdateRestaurantMenuForecastForAllMenuItems();
    end;

    procedure UpdateRestaurantMenuForecast(Item: Record Item)
    begin
        DoUpdateRestaurantMenuForecast(Item);
    end;


    local procedure DoUpdateRestaurantMenuForecastForAllMenuItems()
    var
        MFSetup: Record "AIR Menu Forecast Setup";
        Item: Record Item;
    begin
        if not MFSetup.IsMenuForecastProperlyConfigured() then
            exit;

        Item.SetRange("Item Category Code", MFSetup."Menu Item Category");
        if Item.FindSet() then
            repeat
                Item.UpdateRestaurantMenuForecast();
            until Item.Next() = 0;
    end;

    local procedure DoUpdateRestaurantMenuForecast(Item: Record Item)
    var
        TimeSeries: Record Date;
        ForecastStartDate: Date;
    begin
        ForecastStartDate := WorkDate();

        TimeSeries.Setrange("Period Type", TimeSeries."Period Type"::Date);
        TimeSeries.SetRange("Period Start", ForecastStartDate, CalcDate('<7D>', ForecastStartDate));
        if TimeSeries.FindSet() then
            repeat
                PredictMenuItemSalesForecastUsingML(Item, TimeSeries."Period Start");
            until TimeSeries.Next() = 0;
    end;

    local procedure PredictMenuItemSalesForecastUsingML(Item: Record Item; ForecastDate: Date)
    var
        AzureMLConnector: Codeunit "Azure ML Connector";
        APIKey: text;
        Uri: Text;
        PredictionSales: Text;
    begin
        APIKey := '0I/iD1LnQqY0GW+dR/qgMC0QptWyLi97afaUBic2G5VYBHeNtq53SPfRShMApY3O4Exi5BBIjToQer6o1e+vbQ==';
        Uri := 'https://europewest.services.azureml.net/subscriptions/57b61b3f20b1400ea1d2c8d894e54803/services/37be88c18f35472d8f09c0d3294b84ab/execute?api-version=2.0&details=true';

        AzureMLConnector.Initialize(APIKey, Uri, 30);
        AzureMLConnector.SetInputName('input1');
        AzureMLConnector.SetOutputName('output1');

        AzureMLConnector.AddInputColumnName('date');
        AzureMLConnector.AddInputColumnName('stock_count');
        AzureMLConnector.AddInputColumnName('menu_item_id');
        AzureMLConnector.AddInputColumnName('in_children_menu');
        AzureMLConnector.AddInputColumnName('fest_name');
        AzureMLConnector.AddInputColumnName('Children_Event');
        AzureMLConnector.AddInputColumnName('Music_Event');
        AzureMLConnector.AddInputColumnName('max_stock_quantity');

        AzureMLConnector.AddInputRow();

        AzureMLConnector.AddInputValue(Format(ForecastDate));
        AzureMLConnector.AddInputValue(Format(Item.GetCurrentInventory));
        AzureMLConnector.AddInputValue(Item."No. 2");
        AzureMLConnector.AddInputValue(Format(CheckIfItemMenuBelongsToChildrenMenu(Item)));
        AzureMLConnector.AddInputValue(''); //modify that
        AzureMLConnector.AddInputValue('0'); //modify that
        AzureMLConnector.AddInputValue('0'); //modify that
        AzureMLConnector.AddInputValue('0'); //modify that

        AzureMLConnector.SendToAzureML(false);

        IF AzureMLConnector.GetOutput(1, 1, PredictionSales) then
            PopulateForecastResult(Item."No.", ForecastDate, PredictionSales)
    end;

    local procedure CheckIfItemMenuBelongsToChildrenMenu(Item: Record Item): Integer
    var
        MFInit: Codeunit "AIR MenuForecast Init";
        MFItemAttributesMgt: Codeunit "AIR MF Item Attributes Mgt.";
    begin
        if MFItemAttributesMgt.GetMenuTypeValueFromItem(Item) = MFInit.GetDefaultChildrenMenuAttributeValue() then
            exit(1);
        exit(0);
    end;

    local procedure PopulateForecastResult(ItemNo: Code[20]; ForecastDate: Date; PredictionSales: Text)
    var
        PredictionValue: Decimal;
        MFPopulate: Codeunit "AIR MenuForecastPopulate";
    begin
        Evaluate(PredictionValue, PredictionSales);
        MFPopulate.PopulateForecastResult(ItemNo, ForecastDate, PredictionValue);
    end;
}