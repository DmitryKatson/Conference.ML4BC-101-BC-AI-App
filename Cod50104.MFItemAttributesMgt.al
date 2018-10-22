codeunit 50104 "AIR MF Item Attributes Mgt."
{

    procedure GetItemAttributeID(AttributeName: Text): Integer
    var
        ItemAttribute: Record "Item Attribute";
    begin
        if AttributeName = '' then
            exit(0);

        With ItemAttribute do begin
            SetFilter(Name, AttributeName);
            if FindFirst() then
                exit(ID);
            exit(0);
        end;
    end;

    procedure GetItemAttributeValueID(AttributeId: Integer; AttributValue: Text): Integer
    var
        ItemAttributeValue: Record "Item Attribute Value";
    begin
        if AttributeId = 0 then
            exit(0);
        if AttributValue = '' then
            exit(0);

        With ItemAttributeValue do begin
            SetFilter(Value, AttributValue);
            SetRange("Attribute ID", AttributeId);
            if FindFirst() then
                exit(ID);
            exit(0);
        end;
    end;

    procedure GetItemAttributeValue(AttributeId: Integer; AttributValueId: Integer): Text
    var
        ItemAttributeValue: Record "Item Attribute Value";
    begin
        if AttributeId = 0 then
            exit('');
        if AttributValueId = 0 then
            exit('');

        With ItemAttributeValue do begin
            SetRange("Attribute ID", AttributeId);
            SetRange(ID, AttributValueId);
            if FindFirst() then
                exit(Value);
            exit('');
        end;
    end;


    procedure GetMenuTypeValueFromItem(Item: Record Item): Text
    var
        ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
        MFSetup: Record "AIR Menu Forecast Setup";
    begin
        if Not MFSetup.IsMenuForecastProperlyConfigured() then
            exit('');

        with ItemAttributeValueMapping do begin
            SetRange("Table ID", Database::Item);
            SetRange("No.", Item."No.");
            SetRange("Item Attribute ID", GetItemAttributeID(MFSetup."Menu Attribute"));
            if FindFirst() then
                exit(GetItemAttributeValue("Item Attribute ID", "Item Attribute Value ID"))
        end;
    end;
}