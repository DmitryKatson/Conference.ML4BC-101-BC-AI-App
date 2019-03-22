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
        MenuForecastPopulate: Codeunit "AIR MenuForecastPopulate";
    begin
        MenuForecastPopulate.PrepareForecast(Item."No.");

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
        MFSetup: Record "AIR Menu Forecast Setup";
    begin
        if Not MFSetup.IsMenuForecastProperlyConfigured() then
            exit;

        APIKey := MFSetup."API Key ID";
        Uri := MFSetup."API URI";

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
        // repeat the same for all columns in the API input schema

        AzureMLConnector.AddInputRow();

        AzureMLConnector.AddInputValue(Format(ForecastDate));
        AzureMLConnector.AddInputValue(Format(Item.GetCurrentInventory));
        AzureMLConnector.AddInputValue(Item."No. 2");
        AzureMLConnector.AddInputValue(Format(CheckIfItemMenuBelongsToChildrenMenu(Item)));
        AzureMLConnector.AddInputValue(GetFestivalName(ForecastDate));
        AzureMLConnector.AddInputValue(Format(CheckIfChildrenEvent(ForecastDate)));
        AzureMLConnector.AddInputValue(Format(CheckIfMusicEvent(ForecastDate)));
        AzureMLConnector.AddInputValue(Format(Item."Maximum Inventory"));
        // repeat the same for all columns in the API input schema

        AzureMLConnector.SendToAzureML();

        IF AzureMLConnector.GetOutput(1, 1, PredictionSales) then //change AML output schema, if needed
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

    local procedure GetFestivalName(ForecastDate: Date): Text
    var
        MFEvent: Record "AIR MF Event Schedule";
    begin
        IF Not MFEvent.Get(ForecastDate, MFEvent."Event Type"::Festival) then
            exit('');
        exit(MFEvent."Event Name");
    end;

    local procedure CheckIfChildrenEvent(ForecastDate: Date): Integer
    var
        MFEvent: Record "AIR MF Event Schedule";
    begin
        IF Not MFEvent.Get(ForecastDate, MFEvent."Event Type"::"Children Event") then
            exit(0);
        exit(1);
    end;

    local procedure CheckIfMusicEvent(ForecastDate: Date): Integer
    var
        MFEvent: Record "AIR MF Event Schedule";
    begin
        IF Not MFEvent.Get(ForecastDate, MFEvent."Event Type"::"Music Event") then
            exit(0);
        exit(1);
    end;

    local procedure PopulateForecastResult(ItemNo: Code[20]; ForecastDate: Date; PredictionSales: Text)
    var
        PredictionValue: Decimal;
        MFPopulate: Codeunit "AIR MenuForecastPopulate";
    begin
        Evaluate(PredictionValue, PredictionSales);
        MFPopulate.PopulateForecastResult(ItemNo, ForecastDate, PredictionValue);
    end;


    local procedure PredictSomethingUsingML(featureValue1: text; featureValue2: text) prediction: text
    var
        AzureMLConnector: Codeunit "Azure ML Connector";
        APIKey: text;
        Uri: Text;

    begin
        APIKey := 'some key';
        Uri := 'some uri';

        AzureMLConnector.Initialize(APIKey, Uri, 30);
        AzureMLConnector.SetInputName('input1');
        AzureMLConnector.SetOutputName('output1');

        AzureMLConnector.AddInputColumnName('feature1');
        AzureMLConnector.AddInputColumnName('feature2');
        // repeat the same for all columns in the API input schema

        AzureMLConnector.AddInputRow();

        AzureMLConnector.AddInputValue(featureValue1);
        AzureMLConnector.AddInputValue(featureValue2);
        // repeat the same for all columns in the API input schema

        AzureMLConnector.SendToAzureML();

        if not AzureMLConnector.GetOutput(1, 1, prediction) then //change AML output schema, if needed
            exit('0');

    end;

}